class HijriConverter {
  static const List<String> _monthNames = [
    'Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir',
    'Cemaziyelevvel', 'Cemaziyelahir', 'Recep', 'Şaban',
    'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce',
  ];

  // Tabular Islamic calendar (Friday epoch) — accurate to ±1 day for Turkey
  static String toHijriString(DateTime gregorian) {
    final jd = _gregorianToJulianDay(gregorian);
    final hijri = _julianDayToHijri(jd);
    return '${hijri[2]} ${_monthNames[hijri[1] - 1]} ${hijri[0]}';
  }

  static int _gregorianToJulianDay(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    final a = (14 - m) ~/ 12;
    final yr = y + 4800 - a;
    final mr = m + 12 * a - 3;
    return d +
        (153 * mr + 2) ~/ 5 +
        365 * yr +
        yr ~/ 4 -
        yr ~/ 100 +
        yr ~/ 400 -
        32045;
  }

  // Returns [year, month, day] in Hijri
  static List<int> _julianDayToHijri(int jd) {
    final l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    final ll = l - 10631 * n + 354;
    final j = ((10985 - ll) ~/ 5316) * ((50 * ll) ~/ 17719) +
        (ll ~/ 5670) * ((43 * ll) ~/ 15238);
    final lll = ll - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * lll) ~/ 709;
    final day = lll - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return [year, month, day];
  }
}
