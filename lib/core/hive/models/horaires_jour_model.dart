import 'package:hive/hive.dart';

part 'horaires_jour_model.g.dart';

@HiveType(typeId: 1)
class HorairesJourModel extends HiveObject {
  HorairesJourModel();

  @HiveField(0)
  late String date;

  @HiveField(1)
  late String dateHijri;

  @HiveField(2)
  late String imsak;

  @HiveField(3)
  late String gunes;

  @HiveField(4)
  late String ogle;

  @HiveField(5)
  late String ikindi;

  @HiveField(6)
  late String aksam;

  @HiveField(7)
  late String yatsi;

  factory HorairesJourModel.fromJson(Map<String, dynamic> json) {
    final model = HorairesJourModel()
      ..date = _parseDate(json['date'] as String? ?? '')
      ..dateHijri = json['date_hijri'] as String? ?? ''
      ..imsak = json['imsak'] as String? ?? '00:00'
      ..gunes = json['gunes'] as String? ?? '00:00'
      ..ogle = json['ogle'] as String? ?? '00:00'
      ..ikindi = json['ikindi'] as String? ?? '00:00'
      ..aksam = json['aksam'] as String? ?? '00:00'
      ..yatsi = json['yatsi'] as String? ?? '00:00';
    return model;
  }

  static String _parseDate(String apiDate) {
    // API returns e.g. "13 Haziran 2026 Cumartesi" — we normalize to YYYY-MM-DD
    const months = {
      'Ocak': '01', 'Şubat': '02', 'Mart': '03', 'Nisan': '04',
      'Mayıs': '05', 'Haziran': '06', 'Temmuz': '07', 'Ağustos': '08',
      'Eylül': '09', 'Ekim': '10', 'Kasım': '11', 'Aralık': '12',
    };
    try {
      final parts = apiDate.split(' ');
      if (parts.length >= 3) {
        final day = parts[0].padLeft(2, '0');
        final month = months[parts[1]] ?? '01';
        final year = parts[2];
        return '$year-$month-$day';
      }
    } catch (_) {}
    return apiDate;
  }

  String timeForPrayer(String key) {
    switch (key) {
      case 'imsak': return imsak;
      case 'gunes': return gunes;
      case 'ogle': return ogle;
      case 'ikindi': return ikindi;
      case 'aksam': return aksam;
      case 'yatsi': return yatsi;
      default: return '00:00';
    }
  }

  DateTime timeAsDateTime(String key, DateTime referenceDate) {
    final timeStr = timeForPrayer(key);
    final parts = timeStr.split(':');
    if (parts.length < 2) return referenceDate;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      hour,
      minute,
    );
  }

  static const List<String> prayerKeys = [
    'imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'
  ];
}
