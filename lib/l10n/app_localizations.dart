import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Namaz Vakitleri'**
  String get appTitle;

  /// No description provided for @nextPrayer.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Namaz'**
  String get nextPrayer;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @city.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get city;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @reminderBefore.
  ///
  /// In tr, this message translates to:
  /// **'dakika önce hatırlat'**
  String get reminderBefore;

  /// No description provided for @imsak.
  ///
  /// In tr, this message translates to:
  /// **'İmsak'**
  String get imsak;

  /// No description provided for @gunes.
  ///
  /// In tr, this message translates to:
  /// **'Güneş'**
  String get gunes;

  /// No description provided for @ogle.
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get ogle;

  /// No description provided for @ikindi.
  ///
  /// In tr, this message translates to:
  /// **'İkindi'**
  String get ikindi;

  /// No description provided for @aksam.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get aksam;

  /// No description provided for @yatsi.
  ///
  /// In tr, this message translates to:
  /// **'Yatsı'**
  String get yatsi;

  /// No description provided for @offlineMode.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı Mod'**
  String get offlineMode;

  /// No description provided for @refreshData.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Yenile'**
  String get refreshData;

  /// No description provided for @selectCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehir Seç'**
  String get selectCity;

  /// No description provided for @selectProvince.
  ///
  /// In tr, this message translates to:
  /// **'İl Seç'**
  String get selectProvince;

  /// No description provided for @selectDistrict.
  ///
  /// In tr, this message translates to:
  /// **'İlçe Seç'**
  String get selectDistrict;

  /// No description provided for @darkMode.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Mod'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık Mod'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Modu'**
  String get systemMode;

  /// No description provided for @prayerTime.
  ///
  /// In tr, this message translates to:
  /// **'{prayer} Vakti'**
  String prayerTime(String prayer);

  /// No description provided for @minutes.
  ///
  /// In tr, this message translates to:
  /// **'{count} dakika'**
  String minutes(int count);

  /// No description provided for @dataStale.
  ///
  /// In tr, this message translates to:
  /// **'Veriler güncel olmayabilir'**
  String get dataStale;

  /// No description provided for @noConnection.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get noConnection;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @welcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get welcome;

  /// No description provided for @chooseLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil seçin'**
  String get chooseLanguage;

  /// No description provided for @chooseCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehrinizi seçin'**
  String get chooseCity;

  /// No description provided for @startApp.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get startApp;

  /// No description provided for @calendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get calendar;

  /// No description provided for @hijriDate.
  ///
  /// In tr, this message translates to:
  /// **'Hicri Tarih'**
  String get hijriDate;

  /// No description provided for @province.
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get province;

  /// No description provided for @district.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get district;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @errorLoadingData.
  ///
  /// In tr, this message translates to:
  /// **'Veri yüklenirken hata oluştu'**
  String get errorLoadingData;

  /// No description provided for @appVersion.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Sürümü'**
  String get appVersion;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get home;

  /// No description provided for @reminderDelay.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Süresi'**
  String get reminderDelay;

  /// No description provided for @notificationSound.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Sesi'**
  String get notificationSound;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @noDataOffline.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı veri yok. Lütfen internet bağlantısını kontrol edin.'**
  String get noDataOffline;

  /// No description provided for @dataUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Veriler güncellendi'**
  String get dataUpdated;

  /// No description provided for @prayerReminder.
  ///
  /// In tr, this message translates to:
  /// **'{prayer} vakti {minutes} dakika sonra'**
  String prayerReminder(String prayer, int minutes);

  /// No description provided for @currentPrayer.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Namaz'**
  String get currentPrayer;

  /// No description provided for @timeRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Süre'**
  String get timeRemaining;

  /// No description provided for @hijri.
  ///
  /// In tr, this message translates to:
  /// **'Hicri'**
  String get hijri;

  /// No description provided for @gregorian.
  ///
  /// In tr, this message translates to:
  /// **'Miladi'**
  String get gregorian;

  /// No description provided for @searchCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehir ara...'**
  String get searchCity;

  /// No description provided for @searchDistrict.
  ///
  /// In tr, this message translates to:
  /// **'İlçe ara...'**
  String get searchDistrict;

  /// No description provided for @notificationEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim açık'**
  String get notificationEnabled;

  /// No description provided for @notificationDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim kapalı'**
  String get notificationDisabled;

  /// No description provided for @serverError.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu hatası. Lütfen tekrar deneyin.'**
  String get serverError;

  /// No description provided for @updateRequired.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama güncellemesi gerekli'**
  String get updateRequired;

  /// No description provided for @permissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni reddedildi'**
  String get permissionDenied;

  /// No description provided for @enableNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri Etkinleştir'**
  String get enableNotifications;

  /// No description provided for @minutesBefore5.
  ///
  /// In tr, this message translates to:
  /// **'5 dakika önce'**
  String get minutesBefore5;

  /// No description provided for @minutesBefore10.
  ///
  /// In tr, this message translates to:
  /// **'10 dakika önce'**
  String get minutesBefore10;

  /// No description provided for @minutesBefore15.
  ///
  /// In tr, this message translates to:
  /// **'15 dakika önce'**
  String get minutesBefore15;

  /// No description provided for @minutesBefore30.
  ///
  /// In tr, this message translates to:
  /// **'30 dakika önce'**
  String get minutesBefore30;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
