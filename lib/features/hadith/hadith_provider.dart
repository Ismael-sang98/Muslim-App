import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/api/hadith_api_service.dart';
import '../../core/config/hadith_editions.dart';
import '../../core/hive/hive_service.dart';
import '../settings/settings_provider.dart';

// ── Result wrapper ─────────────────────────────────────────────────────────────

class HadithResult {
  final HadithEditionData data;
  final bool usedFallback;
  final String edition;

  const HadithResult({
    required this.data,
    required this.usedFallback,
    required this.edition,
  });
}

// ── Providers ──────────────────────────────────────────────────────────────────

// Unified with the app language: the hadith content follows settings.langue.
final hadithLangueProvider = Provider<String>(
  (ref) => ref.watch(settingsProvider).langue,
);

final selectedHadithCollectionProvider = StateProvider<String>(
  (_) => 'bukhari',
);

final hadithDataProvider = FutureProvider<HadithResult>((ref) async {
  final lang = ref.watch(hadithLangueProvider);
  final coll = ref.watch(selectedHadithCollectionProvider);
  final svc = ref.read(hadithApiServiceProvider);

  String? edition = editionFor(lang, coll);
  final usedFallback = edition == null && lang != 'en';
  if (usedFallback) {
    debugPrint('[HadithProvider] Fallback: $coll not available in $lang, using "en"');
    edition = editionFor('en', coll);
  }
  if (edition == null) {
    throw Exception('Collection "$coll" introuvable dans toutes les langues');
  }

  final box = HiveService.hadithCacheBox;
  final cached = box.get(edition);
  if (cached != null) {
    try {
      final map = Map<String, dynamic>.from(jsonDecode(cached) as Map);
      debugPrint('[HadithProvider] Cache HIT for $edition');
      return HadithResult(
        data: HadithEditionData.fromJson(map),
        usedFallback: usedFallback,
        edition: edition,
      );
    } catch (_) {
      debugPrint('[HadithProvider] Cache entry corrupt for $edition, deleting');
      await box.delete(edition);
    }
  }

  debugPrint('[HadithProvider] Cache MISS for $edition — fetching...');
  final data = await svc.fetchEdition(edition);
  await box.put(edition, jsonEncode(data.toJson()));
  debugPrint('[HadithProvider] Fetched and cached $edition');
  return HadithResult(
    data: data,
    usedFallback: usedFallback,
    edition: edition,
  );
});

// ── Hadith of the day ───────────────────────────────────────────────────────────

class HadithOfDay {
  final HadithItem item;
  final String collectionName;

  const HadithOfDay({required this.item, required this.collectionName});
}

/// Picks a single hadith, stable for the whole day, from Sahih al-Bukhari
/// in the user's hadith language. Reuses the shared Hive cache.
final hadithOfTheDayProvider = FutureProvider<HadithOfDay?>((ref) async {
  final lang = ref.watch(hadithLangueProvider);
  const coll = 'bukhari';
  final svc = ref.read(hadithApiServiceProvider);

  final edition = editionFor(lang, coll) ?? editionFor('en', coll);
  if (edition == null) return null;

  final box = HiveService.hadithCacheBox;
  HadithEditionData data;
  final cached = box.get(edition);
  if (cached != null) {
    try {
      data = HadithEditionData.fromJson(
        Map<String, dynamic>.from(jsonDecode(cached) as Map),
      );
    } catch (_) {
      await box.delete(edition);
      data = await svc.fetchEdition(edition);
      await box.put(edition, jsonEncode(data.toJson()));
    }
  } else {
    data = await svc.fetchEdition(edition);
    await box.put(edition, jsonEncode(data.toJson()));
  }

  final items = data.hadiths.where((h) => h.text.trim().isNotEmpty).toList();
  if (items.isEmpty) return null;

  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  final item = items[dayOfYear % items.length];
  return HadithOfDay(item: item, collectionName: data.collectionName);
});

// ── Reading UI state ────────────────────────────────────────────────────────────

/// Free-text search query (matches hadith text or number). Ephemeral.
final hadithSearchProvider = StateProvider<String>((_) => '');

/// Reading font size for hadith text. Ephemeral, clamped 12–22.
final hadithFontSizeProvider = StateProvider<double>((_) => 14);

/// When true, the list shows only favorited hadiths.
final hadithShowFavoritesProvider = StateProvider<bool>((_) => false);

// ── Favorites ───────────────────────────────────────────────────────────────────

class HadithFavorite {
  final String edition;
  final String collectionName;
  final int number;
  final String text;
  final String grade;

  const HadithFavorite({
    required this.edition,
    required this.collectionName,
    required this.number,
    required this.text,
    required this.grade,
  });

  String get key => '$edition#$number';

  HadithItem toItem() =>
      HadithItem(number: number, text: text, grade: grade);

  Map<String, dynamic> toJson() => {
        'edition': edition,
        'collectionName': collectionName,
        'number': number,
        'text': text,
        'grade': grade,
      };

  factory HadithFavorite.fromJson(Map<String, dynamic> json) => HadithFavorite(
        edition: json['edition'] as String? ?? '',
        collectionName: json['collectionName'] as String? ?? '',
        number: (json['number'] as num?)?.toInt() ?? 0,
        text: json['text'] as String? ?? '',
        grade: json['grade'] as String? ?? '',
      );
}

class HadithFavoritesNotifier extends StateNotifier<List<HadithFavorite>> {
  final Box<String> _box;

  HadithFavoritesNotifier(this._box) : super(_load(_box));

  static List<HadithFavorite> _load(Box<String> box) {
    final list = <HadithFavorite>[];
    for (final raw in box.values) {
      try {
        list.add(HadithFavorite.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map),
        ));
      } catch (_) {
        // skip corrupt entry
      }
    }
    list.sort((a, b) => a.number.compareTo(b.number));
    return list;
  }

  bool isFavorite(String edition, int number) =>
      state.any((f) => f.edition == edition && f.number == number);

  Future<void> toggle(HadithFavorite fav) async {
    if (isFavorite(fav.edition, fav.number)) {
      await _box.delete(fav.key);
    } else {
      await _box.put(fav.key, jsonEncode(fav.toJson()));
    }
    state = _load(_box);
  }
}

final hadithFavoritesProvider =
    StateNotifierProvider<HadithFavoritesNotifier, List<HadithFavorite>>(
  (_) => HadithFavoritesNotifier(HiveService.hadithFavoritesBox),
);

// ── Reading progress ──────────────────────────────────────────────────────────────

/// Tracks the last read hadith number per collection (e.g. 'bukhari' → 342).
/// Numbering is consistent across languages, so progress is stored by
/// collection key and shared between TR/FR/EN.
class HadithProgressNotifier extends StateNotifier<Map<String, int>> {
  final Box<String> _box;

  HadithProgressNotifier(this._box) : super(_load(_box));

  static Map<String, int> _load(Box<String> box) {
    final map = <String, int>{};
    for (final key in box.keys) {
      final value = int.tryParse(box.get(key) ?? '');
      if (value != null) map[key.toString()] = value;
    }
    return map;
  }

  Future<void> setLastRead(String collection, int number) async {
    if (state[collection] == number) return;
    await _box.put(collection, number.toString());
    state = {...state, collection: number};
  }
}

final hadithProgressProvider =
    StateNotifierProvider<HadithProgressNotifier, Map<String, int>>(
  (_) => HadithProgressNotifier(HiveService.hadithProgressBox),
);
