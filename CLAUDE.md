# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Muslim App** (`namaz_vakti`) — a trilingual (TR/EN/FR) Flutter Android app for Muslims in Turkey: Diyanet prayer times, Quran, Hadith, and a Qibla compass.

## Critical constraint

`lib/core/config/quran_config.dart` is **gitignored** (it holds the Quran API key/`X-Auth-Token`). **Never commit it.** A fresh clone must create it manually — the app won't compile without `QuranConfig.apiKey`.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after ANY change to @HiveField / Hive models
flutter gen-l10n                                            # after editing lib/l10n/*.arb
flutter run
dart analyze lib/ test/                                     # keep at 0 issues before finishing
flutter test                                                # whole suite
flutter test test/reliability_test.dart                     # one file
flutter test --plain-name "start of Ramadan"               # one test by name
flutter build apk --release
```

Two codegen steps are easy to forget and cause confusing errors: **`build_runner`** (regenerates `*.g.dart` Hive adapters) and **`flutter gen-l10n`** (regenerates `lib/l10n/app_localizations*.dart` from the ARB files, driven by `l10n.yaml`). Run the matching one whenever you touch a Hive model or an ARB.

## Architecture

Standard `core/` (cross-cutting) + `features/<name>/` (screens + their providers) split. State is **Riverpod**, persistence is **Hive**, HTTP is **Dio**. There is **no router**: `MaterialApp(home:)` + a custom bottom nav; sub-screens open with `Navigator.push`.

### Navigation
Bottom nav is driven by `activeTabProvider` (a `StateProvider<int>` living in `features/quran/quran_provider.dart`) over an `IndexedStack` of 4 screens in `main.dart`: Home, **HubScreen** (`features/hub/`), Quran, Settings. The Hub ("Keşfet/Explore/Découvrir") is a landing screen that `Navigator.push`es to CalendarScreen and HadithScreen — Calendar and Hadith are **not** bottom-nav tabs.

### Persistence (Hive)
- Adapter-backed boxes use fixed `typeId`s that **must not change**: `SettingsModel`=0, `HorairesJourModel`=1, `PrayerCacheModel`=2. Adapters are registered in `HiveService.init()` in that order.
- Everything else is stored as JSON in `Box<String>` boxes with **no adapter** (quran cache, hadith cache, hadith favorites, hadith progress). This is the pattern to follow for new cached data — avoid new TypeAdapters.
- `HiveService` exposes a `_hadithSchemaVersion`: on `init()`, if the stored schema key differs, the hadith cache box is cleared. **Bump this version** when the cached hadith JSON shape changes, so stale entries are dropped on next launch.
- Settings live at box key `0`; `getOrCreateSettings()` is the single accessor.

### Internationalization (the app-wide system)
- ARB files: `lib/l10n/app_{tr,en,fr}.arb`; `app_tr.arb` is the template (placeholder metadata goes there). Regenerate with `flutter gen-l10n`.
- In widgets: `AppLocalizations.of(context).<key>`.
- **Language is unified**: `settings.langue` drives the UI locale (`appLocaleProvider` → `MaterialApp.locale`) **and** the Quran/Hadith content language. `hadithLangueProvider` and `selectedQuranLanguageProvider` are derived `Provider`s reading `settings.langue` — there is no separate content-language picker.
- **No-context localization**: code without a `BuildContext` (notably `NotificationService`) resolves strings via `lookupAppLocalizations(Locale(lang))`, reading the language from `HiveService.getOrCreateSettings().langue`.
- Shared non-widget strings (prayer names, month/weekday names, compass points) live in `core/utils/localized_names.dart` — reuse `prayerName(l10n, key)`, `localizedMonth(...)`, etc. instead of re-hardcoding.
- First launch (`main.dart`): if no settings exist yet, the app language defaults to the **device locale** when it's tr/en/fr, else `tr`.

### APIs (`core/api/`)
Dio services with an `ApiException` hierarchy (`api_exceptions.dart`) and timeouts. Sources: Diyanet (prayer times), quran.com-style API (needs the gitignored key), and `fawazahmed0/hadith-api` (CDN). The hadith service fetches `{edition}.min.json` and falls back to `.json`; edition availability per language comes from `core/config/hadith_editions.dart` (`editionFor(lang, collection)`, `null` → fall back to English).

### Notifications (`core/notifications/notification_service.dart`)
Static class scheduling a month of per-prayer reminders + at-time + a persistent "next prayer" notification via `flutter_local_notifications`, timezone hardcoded to `Europe/Istanbul`. It has no `BuildContext`, so it localizes via `lookupAppLocalizations` off the Hive language. Because notifications are queued in advance, **rescheduling is required after changes** to language, city, or reminder minutes (callers in `settings_screen.dart`, `home_provider.dart`, and on app resume in `home_screen.dart` handle this).

## Tests

`test/hadith_api_service_test.dart` (Dio mocked with `mocktail`: fallback, timeout, error mapping, grade/chapter parsing) and `test/reliability_test.dart` (pure logic: Hijri conversion, prayer-time parsing, `localized_names` utils). These avoid Hive/plugin/network setup — keep new unit tests to pure logic where possible.
