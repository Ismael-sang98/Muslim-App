import '../../l10n/app_localizations.dart';

/// Localized display name for a prayer key (imsak, gunes, ogle, …).
String prayerName(AppLocalizations l10n, String key) => switch (key) {
      'imsak' => l10n.imsak,
      'gunes' => l10n.gunes,
      'ogle' => l10n.ogle,
      'ikindi' => l10n.ikindi,
      'aksam' => l10n.aksam,
      'yatsi' => l10n.yatsi,
      _ => key,
    };

const _monthsTr = [
  '',
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

const _monthsEn = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _monthsFr = [
  '',
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// Localized month name for [month] (1–12) in the given [langCode] (tr/en/fr).
String localizedMonth(String langCode, int month) {
  final list = switch (langCode) {
    'en' => _monthsEn,
    'fr' => _monthsFr,
    _ => _monthsTr,
  };
  return (month >= 1 && month <= 12) ? list[month] : '';
}

const _weekdaysShortTr = ['', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const _weekdaysShortEn = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdaysShortFr = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

/// Localized short weekday name for [weekday] (1=Mon … 7=Sun).
String localizedWeekdayShort(String langCode, int weekday) {
  final list = switch (langCode) {
    'en' => _weekdaysShortEn,
    'fr' => _weekdaysShortFr,
    _ => _weekdaysShortTr,
  };
  return (weekday >= 1 && weekday <= 7) ? list[weekday] : '';
}

const _weekdaysFullTr = [
  '',
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];
const _weekdaysFullEn = [
  '',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _weekdaysFullFr = [
  '',
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

/// Localized full weekday name for [weekday] (1=Mon … 7=Sun).
String localizedWeekdayFull(String langCode, int weekday) {
  final list = switch (langCode) {
    'en' => _weekdaysFullEn,
    'fr' => _weekdaysFullFr,
    _ => _weekdaysFullTr,
  };
  return (weekday >= 1 && weekday <= 7) ? list[weekday] : '';
}

/// Localized compass point for a cardinal/intercardinal key
/// (N, S, E, W, NE, SE, SW, NW). Turkish uses K/G/D/B, French uses O for West.
String compassLabel(String langCode, String key) {
  const tr = {
    'N': 'K',
    'S': 'G',
    'E': 'D',
    'W': 'B',
    'NE': 'KD',
    'SE': 'GD',
    'SW': 'GB',
    'NW': 'KB',
  };
  const fr = {
    'N': 'N',
    'S': 'S',
    'E': 'E',
    'W': 'O',
    'NE': 'NE',
    'SE': 'SE',
    'SW': 'SO',
    'NW': 'NO',
  };
  return switch (langCode) {
    'tr' => tr[key] ?? key,
    'fr' => fr[key] ?? key,
    _ => key, // English keeps N/S/E/W/…
  };
}
