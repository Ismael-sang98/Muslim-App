import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/api/quran_api_service.dart';
import '../../core/config/quran_config.dart';
import '../../core/hive/hive_service.dart';
import '../settings/settings_provider.dart';

// Global bottom-nav index — lets any screen switch tabs
final activeTabProvider = StateProvider<int>((ref) => 0);

// Quran translation language — unified with the app language (settings.langue).
final selectedQuranLanguageProvider = Provider<String>(
  (ref) => ref.watch(settingsProvider).langue,
);

// ── Helpers ──────────────────────────────────────────────────────────────────

String translationText(Map<String, dynamic> verse, String lang) {
  final targetId = lang == 'tr'
      ? QuranConfig.trId
      : lang == 'fr'
          ? QuranConfig.frId
          : QuranConfig.enId;
  final translations = verse['translations'] as List? ?? [];

  // Try to match by resource_id
  for (final t in translations) {
    final map = t as Map;
    if (map['resource_id'] == targetId) {
      return _stripHtml(map['text'] as String? ?? '');
    }
  }

  // Fallback: positional index — we always request TR(0), FR(1), EN(2)
  final index = lang == 'tr' ? 0 : lang == 'fr' ? 1 : 2;
  if (index < translations.length) {
    return _stripHtml((translations[index] as Map)['text'] as String? ?? '');
  }
  return translations.isNotEmpty
      ? _stripHtml((translations[0] as Map)['text'] as String? ?? '')
      : '';
}

String _stripHtml(String text) => text
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&nbsp;', ' ')
    .trim();

// ── Providers ─────────────────────────────────────────────────────────────────

final chaptersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final box = HiveService.quranCacheBox;
  final cached = box.get('chapters');
  if (cached != null) {
    return (jsonDecode(cached) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
  final chapters = await ref.read(quranApiServiceProvider).fetchChapters();
  await box.put('chapters', jsonEncode(chapters));
  return chapters;
});

final surahVersesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, chapterId) async {
  final box = HiveService.quranCacheBox;
  final key = 'surah_${chapterId}_v3';
  final cached = box.get(key);
  if (cached != null) {
    return (jsonDecode(cached) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
  final verses = await ref.read(quranApiServiceProvider).fetchVersesByChapter(chapterId);
  await box.put(key, jsonEncode(verses));
  return verses;
});


final dailyVerseProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final box = HiveService.quranCacheBox;
  final now = DateTime.now();
  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final cached = box.get('daily_verse');
  if (cached != null) {
    final data = jsonDecode(cached) as Map<String, dynamic>;
    if (data['date'] == todayStr) {
      return Map<String, dynamic>.from(data['verse'] as Map);
    }
  }

  try {
    final verse = await ref.read(quranApiServiceProvider).fetchRandomVerse();
    await box.put('daily_verse', jsonEncode({'date': todayStr, 'verse': verse}));
    return verse;
  } catch (_) {
    return null;
  }
});

final quranSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final lang = ref.watch(selectedQuranLanguageProvider);
  final translationId = lang == 'tr'
      ? QuranConfig.trId
      : lang == 'fr'
          ? QuranConfig.frId
          : QuranConfig.enId;
  return ref.read(quranApiServiceProvider).search(query.trim(), translationId);
});

// ── Arabic font size ──────────────────────────────────────────────────────────

class _FontSizeNotifier extends StateNotifier<double> {
  _FontSizeNotifier() : super(_load());

  static double _load() {
    final v = HiveService.quranCacheBox.get('arabic_font_size');
    return v != null ? double.tryParse(v) ?? 24.0 : 24.0;
  }

  void increase() => _set((state + 2).clamp(16, 40));
  void decrease() => _set((state - 2).clamp(16, 40));

  void _set(double v) {
    state = v;
    HiveService.quranCacheBox.put('arabic_font_size', v.toString());
  }
}

final arabicFontSizeProvider =
    StateNotifierProvider<_FontSizeNotifier, double>((ref) => _FontSizeNotifier());

// ── Last read position ────────────────────────────────────────────────────────

class _LastReadNotifier extends StateNotifier<Map<String, dynamic>?> {
  _LastReadNotifier() : super(_load());

  static Map<String, dynamic>? _load() {
    final v = HiveService.quranCacheBox.get('last_read');
    if (v == null) return null;
    return Map<String, dynamic>.from(jsonDecode(v) as Map);
  }

  void save({
    required int surahId,
    required String surahName,
    required int verseIndex,
  }) {
    final data = {
      'surahId': surahId,
      'surahName': surahName,
      'verseIndex': verseIndex,
    };
    state = data;
    HiveService.quranCacheBox.put('last_read', jsonEncode(data));
  }

  void updateVerseIndex(int index) {
    if (state == null) return;
    final updated = {...state!, 'verseIndex': index};
    state = updated;
    HiveService.quranCacheBox.put('last_read', jsonEncode(updated));
  }
}

final lastReadProvider =
    StateNotifierProvider<_LastReadNotifier, Map<String, dynamic>?>(
        (ref) => _LastReadNotifier());

// ── Favorites ─────────────────────────────────────────────────────────────────

class _FavoritesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  _FavoritesNotifier() : super(_load());

  static List<Map<String, dynamic>> _load() {
    final v = HiveService.quranCacheBox.get('favorites');
    if (v == null) return [];
    return (jsonDecode(v) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  bool isFavorite(String verseKey) =>
      state.any((f) => f['verseKey'] == verseKey);

  void toggle(Map<String, dynamic> favorite) {
    final key = favorite['verseKey'] as String;
    if (isFavorite(key)) {
      state = state.where((f) => f['verseKey'] != key).toList();
    } else {
      state = [...state, favorite];
    }
    HiveService.quranCacheBox.put('favorites', jsonEncode(state));
  }

  void remove(String verseKey) {
    state = state.where((f) => f['verseKey'] != verseKey).toList();
    HiveService.quranCacheBox.put('favorites', jsonEncode(state));
  }
}

final favoritesProvider =
    StateNotifierProvider<_FavoritesNotifier, List<Map<String, dynamic>>>(
        (ref) => _FavoritesNotifier());

// ── Audio ─────────────────────────────────────────────────────────────────────

// ── Reciter selection ─────────────────────────────────────────────────────────

class _ReciterNotifier extends StateNotifier<int> {
  _ReciterNotifier() : super(_load());

  static int _load() {
    final v = HiveService.quranCacheBox.get('selected_reciter');
    return v != null ? int.tryParse(v) ?? 7 : 7;
  }

  void select(int id) {
    state = id;
    HiveService.quranCacheBox.put('selected_reciter', id.toString());
  }
}

final selectedReciterProvider =
    StateNotifierProvider<_ReciterNotifier, int>((ref) => _ReciterNotifier());

final recitersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(quranApiServiceProvider).fetchReciters();
});

// chapterAudioProvider prend (chapterId, reciterId) pour gérer plusieurs récitateurs
final chapterAudioProvider =
    FutureProvider.family<Map<String, String>, (int, int)>((ref, params) async {
  final (chapterId, reciterId) = params;
  return ref.read(quranApiServiceProvider).fetchChapterAudio(chapterId, recitationId: reciterId);
});

class AudioState {
  final String? currentVerseKey;
  final bool isPlaying;
  final bool isLoading;
  final List<String> verseOrder;
  final Map<String, String> urls;

  const AudioState({
    this.currentVerseKey,
    this.isPlaying = false,
    this.isLoading = false,
    this.verseOrder = const [],
    this.urls = const {},
  });

  bool get isActive => currentVerseKey != null;

  AudioState copyWith({
    String? currentVerseKey,
    bool? isPlaying,
    bool? isLoading,
    List<String>? verseOrder,
    Map<String, String>? urls,
    bool clearVerseKey = false,
  }) {
    return AudioState(
      currentVerseKey: clearVerseKey ? null : (currentVerseKey ?? this.currentVerseKey),
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      verseOrder: verseOrder ?? this.verseOrder,
      urls: urls ?? this.urls,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _player = AudioPlayer();
  bool _isBusy = false;

  AudioNotifier() : super(const AudioState()) {
    _player.playerStateStream.listen((ps) {
      if (!mounted) return;
      // Advance only on natural completion, never while loading a new source.
      if (ps.processingState == ProcessingState.completed && !_isBusy) {
        _advance();
      }
      state = state.copyWith(isPlaying: ps.playing);
    });
    // On error: stop cleanly so the user can tap again — don't auto-skip.
    _player.playbackEventStream.listen((_) {}, onError: (Object e, StackTrace _) {
      _isBusy = false;
      if (mounted) state = state.copyWith(isLoading: false, isPlaying: false);
    });
  }

  Future<void> playChapter({
    required String startVerseKey,
    required Map<String, String> urls,
    required List<String> verseOrder,
  }) async {
    if (_isBusy) return;
    _isBusy = true;

    state = state.copyWith(
      currentVerseKey: startVerseKey,
      urls: urls,
      verseOrder: verseOrder,
      isLoading: true,
      isPlaying: false,
    );

    final url = urls[startVerseKey];
    if (url == null) {
      _isBusy = false;
      if (mounted) _advance();
      return;
    }

    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      if (!mounted) { _isBusy = false; return; }
      state = state.copyWith(isLoading: false, isPlaying: true);
      _isBusy = false;
      _player.play();
    } catch (_) {
      _isBusy = false;
      if (mounted) state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  Future<void> togglePause() async {
    _player.playing ? await _player.pause() : await _player.play();
  }

  void playPrevious() {
    if (_isBusy) return;
    final order = state.verseOrder;
    final idx = order.indexOf(state.currentVerseKey ?? '');
    if (idx <= 0) return;
    playChapter(startVerseKey: order[idx - 1], urls: state.urls, verseOrder: order);
  }

  void playNext() {
    if (_isBusy) return;
    _advance();
  }

  Future<void> stop() async {
    _isBusy = false;
    await _player.stop();
    if (mounted) state = const AudioState();
  }

  void _advance() {
    final order = state.verseOrder;
    final idx = order.indexOf(state.currentVerseKey ?? '');
    if (idx < 0 || idx >= order.length - 1) { stop(); return; }
    playChapter(startVerseKey: order[idx + 1], urls: state.urls, verseOrder: order);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioProvider =
    StateNotifierProvider<AudioNotifier, AudioState>((ref) => AudioNotifier());



