// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prayer Times';

  @override
  String get nextPrayer => 'Next Prayer';

  @override
  String get today => 'Today';

  @override
  String get settings => 'Settings';

  @override
  String get city => 'City';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminderBefore => 'minutes before reminder';

  @override
  String get imsak => 'Fajr (Imsak)';

  @override
  String get gunes => 'Sunrise';

  @override
  String get ogle => 'Dhuhr';

  @override
  String get ikindi => 'Asr';

  @override
  String get aksam => 'Maghrib';

  @override
  String get yatsi => 'Isha';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get selectCity => 'Select City';

  @override
  String get selectProvince => 'Select Province';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System Mode';

  @override
  String prayerTime(String prayer) {
    return '$prayer Time';
  }

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String get dataStale => 'Data may be outdated';

  @override
  String get noConnection => 'No internet connection';

  @override
  String get retry => 'Retry';

  @override
  String get welcome => 'Welcome';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get chooseCity => 'Choose your city';

  @override
  String get startApp => 'Get Started';

  @override
  String get calendar => 'Calendar';

  @override
  String get hijriDate => 'Hijri Date';

  @override
  String get province => 'Province';

  @override
  String get district => 'District';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get appVersion => 'App Version';

  @override
  String get home => 'Home';

  @override
  String get reminderDelay => 'Reminder Delay';

  @override
  String get notificationSound => 'Notification Sound';

  @override
  String get theme => 'Theme';

  @override
  String get about => 'About';

  @override
  String get noDataOffline =>
      'No offline data. Please check your internet connection.';

  @override
  String get dataUpdated => 'Data updated';

  @override
  String prayerReminder(String prayer, int minutes) {
    return '$prayer prayer in $minutes minutes';
  }

  @override
  String get currentPrayer => 'Current Prayer';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get hijri => 'Hijri';

  @override
  String get gregorian => 'Gregorian';

  @override
  String get searchCity => 'Search city...';

  @override
  String get searchDistrict => 'Search district...';

  @override
  String get notificationEnabled => 'Notification on';

  @override
  String get notificationDisabled => 'Notification off';

  @override
  String get serverError => 'Server error. Please try again.';

  @override
  String get updateRequired => 'Application update required';

  @override
  String get permissionDenied => 'Notification permission denied';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get minutesBefore5 => '5 minutes before';

  @override
  String get minutesBefore10 => '10 minutes before';

  @override
  String get minutesBefore15 => '15 minutes before';

  @override
  String get minutesBefore30 => '30 minutes before';

  @override
  String get sectionAppearance => 'APPEARANCE';

  @override
  String get sectionLanguage => 'LANGUAGE';

  @override
  String get sectionLocation => 'LOCATION';

  @override
  String get sectionReminder => 'REMINDER';

  @override
  String get sectionNotifications => 'NOTIFICATIONS';

  @override
  String get sectionAbout => 'ABOUT';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get notSelected => 'Not selected';

  @override
  String get aboutApp => 'About the app';

  @override
  String reminderDescription(int count) {
    return 'Get notified $count minutes before each prayer';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get searchHint => 'Search...';

  @override
  String get continueButton => 'Continue';

  @override
  String get otherPrayers => 'Other prayers';

  @override
  String get badgeStale => 'Old';

  @override
  String get badgeOffline => 'Offline';

  @override
  String get exactAlarmsDisabled =>
      'Exact notifications disabled — Tap to enable';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get qiblaSubtitle => 'Find the direction of the Kaaba';

  @override
  String get verseOfTheDay => 'Verse of the Day';

  @override
  String get cityNotSelected => 'No city selected';

  @override
  String get explore => 'Explore';

  @override
  String get calendarSubtitle => 'Monthly prayer times';

  @override
  String get hadith => 'Hadith';

  @override
  String get hadithSubtitle => 'Read authentic collections';

  @override
  String get hadithOfTheDay => 'HADITH OF THE DAY';

  @override
  String get readMore => 'Read more';

  @override
  String get qibla => 'Qibla';

  @override
  String get locationPermissionNeeded =>
      'Location permission is required.\nGrant access to calculate the Qibla direction.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get noMagnetometer => 'No magnetometer sensor found on this device.';

  @override
  String get kaabaMecca => 'Kaaba • Mecca';

  @override
  String get kaabaDirection => 'KAABA DIRECTION';

  @override
  String get facingQibla => 'You are facing the Qibla';

  @override
  String get rotatePhone => 'Rotate your phone';

  @override
  String get quran => 'Quran';

  @override
  String get quranSearchHint => 'Search or type 2:255';

  @override
  String get surahs => 'Surahs';

  @override
  String get verses => 'Verses';

  @override
  String get juz => 'Juz';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get connectionError => 'Connection error.';

  @override
  String get connectionErrorCheckInternet =>
      'Connection error.\nPlease check your internet connection.';

  @override
  String get connectionErrorRetry => 'Connection error. Please try again.';

  @override
  String get noVerseResults => 'No verses found.';

  @override
  String get goDirectly => 'Go directly';

  @override
  String get copyArabic => 'Copy Arabic text';

  @override
  String get copyTranslation => 'Copy translation';

  @override
  String get copied => 'Copied!';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get loadingError => 'Loading error';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoritesYet => 'You haven\'t added any favorites yet.';

  @override
  String get favoritesHint => 'Long-press a verse to add it to favorites.';

  @override
  String get reciter => 'Reciter';

  @override
  String get hadithSearchHint => 'Search (text or no.)...';

  @override
  String get chapters => 'Chapters';

  @override
  String get hadithsLabel => 'hadiths';

  @override
  String get collectionUnavailableInLang =>
      'This collection is not available in the selected language — showing English';

  @override
  String get noResults => 'No results found';

  @override
  String get noFavoriteHadith => 'No favorite hadiths yet';

  @override
  String get favoriteHadithHint => 'Tap ⭐ to add a hadith to your favorites';

  @override
  String get errorTimeout => 'The request timed out. Please try again.';

  @override
  String get errorNoInternet => 'No internet connection. You are offline.';

  @override
  String errorServer(int code) {
    return 'Server error ($code).';
  }

  @override
  String get fontSize => 'Font Size';

  @override
  String resumeReadingAt(int number) {
    return 'Continue where you left off · #$number';
  }

  @override
  String get favorite => 'Favorite';

  @override
  String get favorited => 'Favorited';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get dataSource => 'Data source';

  @override
  String get developer => 'Developer';

  @override
  String get contact => 'Contact';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get locating => 'Locating…';

  @override
  String get locationServiceOff =>
      'Location services are off. Please turn them on.';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String get cityNotDetected =>
      'Couldn\'t detect your city automatically, please select it manually.';

  @override
  String get locationError => 'Couldn\'t get your location.';

  @override
  String get locationOpenSettings =>
      'Location permission is off. Enable it in Settings.';

  @override
  String cityDetected(String city) {
    return '$city selected';
  }

  @override
  String notifReminderTitle(String prayer) {
    return '🕌 $prayer Time';
  }

  @override
  String notifReminderBody(String prayer, int minutes) {
    return '$minutes minutes until $prayer prayer';
  }

  @override
  String notifAtTimeTitle(String prayer) {
    return '🕌 $prayer Time Has Come';
  }

  @override
  String notifAtTimeBody(String prayer) {
    return 'It\'s time for $prayer prayer';
  }
}
