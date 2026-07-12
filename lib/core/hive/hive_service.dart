import 'package:hive_flutter/hive_flutter.dart';
import 'models/settings_model.dart';
import 'models/horaires_jour_model.dart';
import 'models/prayer_cache_model.dart';

class HiveService {
  static const String _settingsBoxName = 'settings';
  static const String _cacheBoxName = 'prayer_cache';

  static const String _quranCacheBoxName  = 'quran_cache';
  static const String _hadithCacheBoxName = 'hadith_cache';
  static const String _hadithFavoritesBoxName = 'hadith_favorites';
  static const String _hadithProgressBoxName = 'hadith_progress';

  // Bump when the cached hadith JSON shape changes (e.g. adding sections),
  // so stale entries are cleared automatically on the next launch.
  static const String _hadithSchemaKey = '__schema__';
  static const String _hadithSchemaVersion = '2';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Registration order MUST match typeId order: 0, 1, 2
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(HorairesJourModelAdapter());
    Hive.registerAdapter(PrayerCacheModelAdapter());
    await Hive.openBox<SettingsModel>(_settingsBoxName);
    await Hive.openBox<PrayerCacheModel>(_cacheBoxName);
    await Hive.openBox<String>(_quranCacheBoxName);
    final hadithBox = await Hive.openBox<String>(_hadithCacheBoxName);
    await Hive.openBox<String>(_hadithFavoritesBoxName);
    await Hive.openBox<String>(_hadithProgressBoxName);

    // Drop stale hadith cache when the stored schema is outdated.
    if (hadithBox.get(_hadithSchemaKey) != _hadithSchemaVersion) {
      await hadithBox.clear();
      await hadithBox.put(_hadithSchemaKey, _hadithSchemaVersion);
    }
  }

  static Box<SettingsModel> get settingsBox =>
      Hive.box<SettingsModel>(_settingsBoxName);

  static Box<PrayerCacheModel> get cacheBox =>
      Hive.box<PrayerCacheModel>(_cacheBoxName);

  static SettingsModel getOrCreateSettings() {
    final box = settingsBox;
    if (box.isEmpty) {
      final defaults = SettingsModel.defaults();
      box.put(0, defaults);
      return defaults;
    }
    return box.getAt(0)!;
  }

  static Future<void> saveCache(PrayerCacheModel cache) async {
    final key = PrayerCacheModel.keyFor(cache.villeId, cache.moisAnnee);
    await cacheBox.put(key, cache);
  }

  static PrayerCacheModel? getCache(String villeId, String moisAnnee) {
    final key = PrayerCacheModel.keyFor(villeId, moisAnnee);
    return cacheBox.get(key);
  }

  static Future<void> clearCache() async {
    await cacheBox.clear();
  }

  static Box<String> get quranCacheBox =>
      Hive.box<String>(_quranCacheBoxName);

  static Box<String> get hadithCacheBox =>
      Hive.box<String>(_hadithCacheBoxName);

  static Box<String> get hadithFavoritesBox =>
      Hive.box<String>(_hadithFavoritesBoxName);

  static Box<String> get hadithProgressBox =>
      Hive.box<String>(_hadithProgressBoxName);
}
