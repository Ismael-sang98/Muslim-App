import 'package:hive_flutter/hive_flutter.dart';
import 'models/settings_model.dart';
import 'models/horaires_jour_model.dart';
import 'models/prayer_cache_model.dart';

class HiveService {
  static const String _settingsBoxName = 'settings';
  static const String _cacheBoxName = 'prayer_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Registration order MUST match typeId order: 0, 1, 2
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(HorairesJourModelAdapter());
    Hive.registerAdapter(PrayerCacheModelAdapter());
    await Hive.openBox<SettingsModel>(_settingsBoxName);
    await Hive.openBox<PrayerCacheModel>(_cacheBoxName);
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
}
