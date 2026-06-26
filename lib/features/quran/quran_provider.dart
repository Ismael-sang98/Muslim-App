import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/quran_api_service.dart';
import '../../core/config/quran_config.dart';
import '../../core/hive/hive_service.dart';

// Global bottom-nav index — lets any screen switch tabs
final activeTabProvider = StateProvider<int>((ref) => 0);

// Selected translation language inside the Quran feature
final selectedQuranLanguageProvider = StateProvider<String>((ref) => 'tr');

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

String _stripHtml(String text) =>
    text.replaceAll(RegExp(r'<[^>]*>'), '').trim();

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
  // v2 : invalide le cache précédent qui ne contenait pas la traduction anglaise
  final key = 'surah_${chapterId}_v2';
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
