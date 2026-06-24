import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 0)
class SettingsModel extends HiveObject {
  @HiveField(0)
  late String villeId;

  @HiveField(1)
  late String villeNom;

  @HiveField(2)
  late String langue;

  @HiveField(3)
  late String themeMode;

  @HiveField(4)
  late Map<dynamic, dynamic> notificationsRaw;

  @HiveField(5)
  late int minutesAvantRappel;

  @HiveField(6)
  String? villeProvinceNom;

  Map<String, bool> get notificationsActives =>
      notificationsRaw.cast<String, bool>();

  void setNotification(String key, bool value) {
    notificationsRaw[key] = value;
  }

  static SettingsModel defaults() {
    final model = SettingsModel()
      ..villeId = ''
      ..villeNom = ''
      ..langue = 'tr'
      ..themeMode = 'system'
      ..notificationsRaw = {
        'imsak': true,
        'gunes': false,
        'ogle': true,
        'ikindi': true,
        'aksam': true,
        'yatsi': true,
      }
      ..minutesAvantRappel = 10;
    return model;
  }
}
