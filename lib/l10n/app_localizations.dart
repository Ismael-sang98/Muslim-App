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

  /// No description provided for @sectionAppearance.
  ///
  /// In tr, this message translates to:
  /// **'GÖRÜNÜM'**
  String get sectionAppearance;

  /// No description provided for @sectionLanguage.
  ///
  /// In tr, this message translates to:
  /// **'DİL'**
  String get sectionLanguage;

  /// No description provided for @sectionLocation.
  ///
  /// In tr, this message translates to:
  /// **'KONUM'**
  String get sectionLocation;

  /// No description provided for @sectionReminder.
  ///
  /// In tr, this message translates to:
  /// **'HATIRLATMA'**
  String get sectionReminder;

  /// No description provided for @sectionNotifications.
  ///
  /// In tr, this message translates to:
  /// **'BİLDİRİMLER'**
  String get sectionNotifications;

  /// No description provided for @sectionAbout.
  ///
  /// In tr, this message translates to:
  /// **'HAKKINDA'**
  String get sectionAbout;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @notSelected.
  ///
  /// In tr, this message translates to:
  /// **'Seçilmedi'**
  String get notSelected;

  /// No description provided for @aboutApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama hakkında'**
  String get aboutApp;

  /// No description provided for @reminderDescription.
  ///
  /// In tr, this message translates to:
  /// **'Her namazdan {count} dakika önce bildirim alın'**
  String reminderDescription(int count);

  /// No description provided for @minutesShort.
  ///
  /// In tr, this message translates to:
  /// **'{count} dk'**
  String minutesShort(int count);

  /// No description provided for @langTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get langTurkish;

  /// No description provided for @langEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langFrench.
  ///
  /// In tr, this message translates to:
  /// **'Français'**
  String get langFrench;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ara...'**
  String get searchHint;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueButton;

  /// No description provided for @otherPrayers.
  ///
  /// In tr, this message translates to:
  /// **'Diğer vakitler'**
  String get otherPrayers;

  /// No description provided for @badgeStale.
  ///
  /// In tr, this message translates to:
  /// **'Eski'**
  String get badgeStale;

  /// No description provided for @badgeOffline.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı'**
  String get badgeOffline;

  /// No description provided for @exactAlarmsDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Tam zamanlı bildirimler kapalı — Etkinleştirmek için dokunun'**
  String get exactAlarmsDisabled;

  /// No description provided for @qiblaDirection.
  ///
  /// In tr, this message translates to:
  /// **'Kıble Yönü'**
  String get qiblaDirection;

  /// No description provided for @qiblaSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kabe\'nin yönünü bul'**
  String get qiblaSubtitle;

  /// No description provided for @verseOfTheDay.
  ///
  /// In tr, this message translates to:
  /// **'Günün Ayeti'**
  String get verseOfTheDay;

  /// No description provided for @cityNotSelected.
  ///
  /// In tr, this message translates to:
  /// **'Şehir seçilmedi'**
  String get cityNotSelected;

  /// No description provided for @explore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get explore;

  /// No description provided for @calendarSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aylık namaz vakitleri'**
  String get calendarSubtitle;

  /// No description provided for @hadith.
  ///
  /// In tr, this message translates to:
  /// **'Hadis'**
  String get hadith;

  /// No description provided for @hadithSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sahih koleksiyonları oku'**
  String get hadithSubtitle;

  /// No description provided for @hadithOfTheDay.
  ///
  /// In tr, this message translates to:
  /// **'GÜNÜN HADİSİ'**
  String get hadithOfTheDay;

  /// No description provided for @readMore.
  ///
  /// In tr, this message translates to:
  /// **'Devamını oku'**
  String get readMore;

  /// No description provided for @qibla.
  ///
  /// In tr, this message translates to:
  /// **'Kıble'**
  String get qibla;

  /// No description provided for @locationPermissionNeeded.
  ///
  /// In tr, this message translates to:
  /// **'Konum iznine ihtiyaç var.\nKıble yönünü hesaplamak için izin verin.'**
  String get locationPermissionNeeded;

  /// No description provided for @grantPermission.
  ///
  /// In tr, this message translates to:
  /// **'İzin Ver'**
  String get grantPermission;

  /// No description provided for @noMagnetometer.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazda manyetometre sensörü bulunamadı.'**
  String get noMagnetometer;

  /// No description provided for @kaabaMecca.
  ///
  /// In tr, this message translates to:
  /// **'Kâbe • Mekke'**
  String get kaabaMecca;

  /// No description provided for @kaabaDirection.
  ///
  /// In tr, this message translates to:
  /// **'KÂBE YÖNÜ'**
  String get kaabaDirection;

  /// No description provided for @facingQibla.
  ///
  /// In tr, this message translates to:
  /// **'Kıbleye dönüyorsunuz'**
  String get facingQibla;

  /// No description provided for @rotatePhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefonu döndürün'**
  String get rotatePhone;

  /// No description provided for @quran.
  ///
  /// In tr, this message translates to:
  /// **'Kuran'**
  String get quran;

  /// No description provided for @quranSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ara veya 2:255 yaz'**
  String get quranSearchHint;

  /// No description provided for @surahs.
  ///
  /// In tr, this message translates to:
  /// **'Sureler'**
  String get surahs;

  /// No description provided for @verses.
  ///
  /// In tr, this message translates to:
  /// **'Ayetler'**
  String get verses;

  /// No description provided for @juz.
  ///
  /// In tr, this message translates to:
  /// **'Cüz'**
  String get juz;

  /// No description provided for @continueReading.
  ///
  /// In tr, this message translates to:
  /// **'Kaldığın yerden devam et'**
  String get continueReading;

  /// No description provided for @connectionError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası.'**
  String get connectionError;

  /// No description provided for @connectionErrorCheckInternet.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası.\nLütfen internet bağlantınızı kontrol edin.'**
  String get connectionErrorCheckInternet;

  /// No description provided for @connectionErrorRetry.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası. Lütfen tekrar deneyin.'**
  String get connectionErrorRetry;

  /// No description provided for @noVerseResults.
  ///
  /// In tr, this message translates to:
  /// **'Ayet sonucu bulunamadı.'**
  String get noVerseResults;

  /// No description provided for @goDirectly.
  ///
  /// In tr, this message translates to:
  /// **'Doğrudan git'**
  String get goDirectly;

  /// No description provided for @copyArabic.
  ///
  /// In tr, this message translates to:
  /// **'Arapça metni kopyala'**
  String get copyArabic;

  /// No description provided for @copyTranslation.
  ///
  /// In tr, this message translates to:
  /// **'Tercümeyi kopyala'**
  String get copyTranslation;

  /// No description provided for @copied.
  ///
  /// In tr, this message translates to:
  /// **'Kopyalandı!'**
  String get copied;

  /// No description provided for @removeFromFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden çıkar'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get addToFavorites;

  /// No description provided for @loadingError.
  ///
  /// In tr, this message translates to:
  /// **'Yükleme hatası'**
  String get loadingError;

  /// No description provided for @favorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get favorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori eklemediniz.'**
  String get noFavoritesYet;

  /// No description provided for @favoritesHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir ayete uzun basarak favorilere ekleyebilirsiniz.'**
  String get favoritesHint;

  /// No description provided for @reciter.
  ///
  /// In tr, this message translates to:
  /// **'Okuyucu'**
  String get reciter;

  /// No description provided for @hadithSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ara (metin veya no)...'**
  String get hadithSearchHint;

  /// No description provided for @chapters.
  ///
  /// In tr, this message translates to:
  /// **'Bölümler'**
  String get chapters;

  /// No description provided for @hadithsLabel.
  ///
  /// In tr, this message translates to:
  /// **'hadis'**
  String get hadithsLabel;

  /// No description provided for @collectionUnavailableInLang.
  ///
  /// In tr, this message translates to:
  /// **'Bu koleksiyon seçilen dilde mevcut değil — İngilizce gösteriliyor'**
  String get collectionUnavailableInLang;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResults;

  /// No description provided for @noFavoriteHadith.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori hadis yok'**
  String get noFavoriteHadith;

  /// No description provided for @favoriteHadithHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir hadisi favorilere eklemek için ⭐ simgesine dokunun'**
  String get favoriteHadithHint;

  /// No description provided for @errorTimeout.
  ///
  /// In tr, this message translates to:
  /// **'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.'**
  String get errorTimeout;

  /// No description provided for @errorNoInternet.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok. Çevrimdışı modda çalışıyorsunuz.'**
  String get errorNoInternet;

  /// No description provided for @errorServer.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu hatası ({code}).'**
  String errorServer(int code);

  /// No description provided for @fontSize.
  ///
  /// In tr, this message translates to:
  /// **'Yazı Boyutu'**
  String get fontSize;

  /// No description provided for @resumeReadingAt.
  ///
  /// In tr, this message translates to:
  /// **'Kaldığınız yerden devam edin · #{number}'**
  String resumeReadingAt(int number);

  /// No description provided for @favorite.
  ///
  /// In tr, this message translates to:
  /// **'Favori'**
  String get favorite;

  /// No description provided for @favorited.
  ///
  /// In tr, this message translates to:
  /// **'Favoride'**
  String get favorited;

  /// No description provided for @copy.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @previous.
  ///
  /// In tr, this message translates to:
  /// **'Önceki'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki'**
  String get next;

  /// No description provided for @dataSource.
  ///
  /// In tr, this message translates to:
  /// **'Veri kaynağı'**
  String get dataSource;

  /// No description provided for @developer.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici'**
  String get developer;

  /// No description provided for @contact.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get contact;

  /// No description provided for @notifReminderTitle.
  ///
  /// In tr, this message translates to:
  /// **'🕌 {prayer} Vakti'**
  String notifReminderTitle(String prayer);

  /// No description provided for @notifReminderBody.
  ///
  /// In tr, this message translates to:
  /// **'{prayer} namazına {minutes} dakika kaldı'**
  String notifReminderBody(String prayer, int minutes);

  /// No description provided for @notifAtTimeTitle.
  ///
  /// In tr, this message translates to:
  /// **'🕌 {prayer} Vakti Girdi'**
  String notifAtTimeTitle(String prayer);

  /// No description provided for @notifAtTimeBody.
  ///
  /// In tr, this message translates to:
  /// **'{prayer} namazının vakti geldi'**
  String notifAtTimeBody(String prayer);
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
