import 'package:hive/hive.dart';
import 'horaires_jour_model.dart';

part 'prayer_cache_model.g.dart';

@HiveType(typeId: 2)
class PrayerCacheModel extends HiveObject {
  @HiveField(0)
  late String moisAnnee;

  @HiveField(1)
  late String villeId;

  @HiveField(2)
  late List<HorairesJourModel> horairesMensuels;

  @HiveField(3)
  late DateTime cachedAt;

  bool get isFresh => DateTime.now().difference(cachedAt).inHours < 24;

  bool get isStale => DateTime.now().difference(cachedAt).inHours >= 48;

  static String keyFor(String villeId, String moisAnnee) =>
      '${villeId}_$moisAnnee';

  static String currentMoisAnnee() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    return '${now.year}-$m';
  }
}
