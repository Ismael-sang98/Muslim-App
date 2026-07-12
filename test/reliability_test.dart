import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_vakti/core/utils/hijri_converter.dart';
import 'package:namaz_vakti/core/utils/localized_names.dart';
import 'package:namaz_vakti/core/hive/models/horaires_jour_model.dart';
import 'package:namaz_vakti/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

void main() {
  // ── HijriConverter ──────────────────────────────────────────────────────────
  group('HijriConverter', () {
    test('start of Ramadan 2024 → 1 Ramazan 1445 (real Diyanet anchor)', () {
      expect(
        HijriConverter.toHijriString(DateTime(2024, 3, 11)),
        '1 Ramazan 1445',
      );
    });

    test('characterization: known dates', () {
      expect(
        HijriConverter.toHijriString(DateTime(2026, 7, 11)),
        '25 Muharrem 1448',
      );
      expect(
        HijriConverter.toHijriString(DateTime(2000, 1, 1)),
        '24 Ramazan 1420',
      );
    });

    test('output is always "<day> <month> <year>" with a valid month', () {
      const validMonths = {
        'Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir',
        'Cemaziyelevvel', 'Cemaziyelahir', 'Recep', 'Şaban',
        'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce',
      };
      // Walk a full year of dates and assert structural invariants.
      var d = DateTime(2025, 1, 1);
      for (var i = 0; i < 366; i++) {
        final s = HijriConverter.toHijriString(d);
        final parts = s.split(' ');
        expect(parts.length, 3, reason: 'bad format for $d: "$s"');
        final day = int.parse(parts[0]);
        expect(day, inInclusiveRange(1, 30), reason: '$d → $s');
        expect(validMonths, contains(parts[1]), reason: '$d → $s');
        expect(int.parse(parts[2]), greaterThan(1400));
        d = d.add(const Duration(days: 1));
      }
    });

    test('consecutive days never jump by more than one Hijri day', () {
      var d = DateTime(2025, 6, 1);
      int? prevDay;
      for (var i = 0; i < 90; i++) {
        final day = int.parse(HijriConverter.toHijriString(d).split(' ')[0]);
        if (prevDay != null) {
          final sameOrNext = day == prevDay + 1;
          final wrapped = day == 1; // new month
          expect(sameOrNext || wrapped, isTrue,
              reason: 'jump $prevDay → $day at $d');
        }
        prevDay = day;
        d = d.add(const Duration(days: 1));
      }
    });
  });

  // ── HorairesJourModel ───────────────────────────────────────────────────────
  group('HorairesJourModel', () {
    test('fromJson normalizes Turkish API date to YYYY-MM-DD', () {
      final m = HorairesJourModel.fromJson({
        'date': '11 Temmuz 2026 Cumartesi',
        'imsak': '03:20',
        'gunes': '05:15',
        'ogle': '13:15',
        'ikindi': '17:10',
        'aksam': '20:45',
        'yatsi': '22:30',
      });
      expect(m.date, '2026-07-11');
      expect(m.imsak, '03:20');
      expect(m.yatsi, '22:30');
    });

    test('fromJson pads single-digit days and maps every month', () {
      expect(
        HorairesJourModel.fromJson({'date': '3 Ocak 2025 Cuma'}).date,
        '2025-01-03',
      );
      expect(
        HorairesJourModel.fromJson({'date': '9 Aralık 2025 Salı'}).date,
        '2025-12-09',
      );
    });

    test('fromJson falls back gracefully on malformed date / missing times', () {
      final m = HorairesJourModel.fromJson({'date': 'garbage'});
      expect(m.date, 'garbage');
      expect(m.imsak, '00:00'); // default when absent
    });

    test('timeForPrayer returns the right field and 00:00 for unknown keys', () {
      final m = HorairesJourModel.fromJson({
        'date': '11 Temmuz 2026',
        'ogle': '13:15',
      });
      expect(m.timeForPrayer('ogle'), '13:15');
      expect(m.timeForPrayer('unknown'), '00:00');
    });

    test('timeAsDateTime combines the prayer time with the reference date', () {
      final m = HorairesJourModel.fromJson({
        'date': '11 Temmuz 2026',
        'ikindi': '17:05',
      });
      final dt = m.timeAsDateTime('ikindi', DateTime(2026, 7, 11));
      expect(dt, DateTime(2026, 7, 11, 17, 5));
    });

    test('prayerKeys are the canonical six in order', () {
      expect(
        HorairesJourModel.prayerKeys,
        ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'],
      );
    });
  });

  // ── Localized names ─────────────────────────────────────────────────────────
  group('localized names', () {
    test('months differ per language and are 1-indexed', () {
      expect(localizedMonth('tr', 7), 'Temmuz');
      expect(localizedMonth('en', 7), 'July');
      expect(localizedMonth('fr', 7), 'juillet');
      expect(localizedMonth('tr', 0), ''); // out of range
      expect(localizedMonth('tr', 13), '');
    });

    test('weekdays: 1=Monday … 7=Sunday', () {
      expect(localizedWeekdayShort('tr', 1), 'Pzt');
      expect(localizedWeekdayFull('en', 6), 'Saturday');
      expect(localizedWeekdayFull('fr', 7), 'dimanche');
    });

    test('compass points localize (TR K/G/D/B, FR uses O/SO/NO)', () {
      expect(compassLabel('tr', 'N'), 'K');
      expect(compassLabel('tr', 'W'), 'B');
      expect(compassLabel('tr', 'SW'), 'GB');
      expect(compassLabel('fr', 'W'), 'O');
      expect(compassLabel('fr', 'NW'), 'NO');
      expect(compassLabel('en', 'W'), 'W'); // English unchanged
    });

    test('prayerName resolves via AppLocalizations per language', () {
      final tr = lookupAppLocalizations(const Locale('tr'));
      final en = lookupAppLocalizations(const Locale('en'));
      expect(prayerName(tr, 'ogle'), 'Öğle');
      expect(prayerName(en, 'ogle'), 'Dhuhr');
      expect(prayerName(tr, 'unknown'), 'unknown'); // fallback
    });
  });
}
