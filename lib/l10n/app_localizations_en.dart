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
}
