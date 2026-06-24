// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Namaz Vakitleri';

  @override
  String get nextPrayer => 'Sonraki Namaz';

  @override
  String get today => 'Bugün';

  @override
  String get settings => 'Ayarlar';

  @override
  String get city => 'Şehir';

  @override
  String get language => 'Dil';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get reminderBefore => 'dakika önce hatırlat';

  @override
  String get imsak => 'İmsak';

  @override
  String get gunes => 'Güneş';

  @override
  String get ogle => 'Öğle';

  @override
  String get ikindi => 'İkindi';

  @override
  String get aksam => 'Akşam';

  @override
  String get yatsi => 'Yatsı';

  @override
  String get offlineMode => 'Çevrimdışı Mod';

  @override
  String get refreshData => 'Verileri Yenile';

  @override
  String get selectCity => 'Şehir Seç';

  @override
  String get selectProvince => 'İl Seç';

  @override
  String get selectDistrict => 'İlçe Seç';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get lightMode => 'Aydınlık Mod';

  @override
  String get systemMode => 'Sistem Modu';

  @override
  String prayerTime(String prayer) {
    return '$prayer Vakti';
  }

  @override
  String minutes(int count) {
    return '$count dakika';
  }

  @override
  String get dataStale => 'Veriler güncel olmayabilir';

  @override
  String get noConnection => 'İnternet bağlantısı yok';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get welcome => 'Hoş Geldiniz';

  @override
  String get chooseLanguage => 'Dil seçin';

  @override
  String get chooseCity => 'Şehrinizi seçin';

  @override
  String get startApp => 'Başla';

  @override
  String get calendar => 'Takvim';

  @override
  String get hijriDate => 'Hicri Tarih';

  @override
  String get province => 'İl';

  @override
  String get district => 'İlçe';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get errorLoadingData => 'Veri yüklenirken hata oluştu';

  @override
  String get appVersion => 'Uygulama Sürümü';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get reminderDelay => 'Hatırlatma Süresi';

  @override
  String get notificationSound => 'Bildirim Sesi';

  @override
  String get theme => 'Tema';

  @override
  String get about => 'Hakkında';

  @override
  String get noDataOffline =>
      'Çevrimdışı veri yok. Lütfen internet bağlantısını kontrol edin.';

  @override
  String get dataUpdated => 'Veriler güncellendi';

  @override
  String prayerReminder(String prayer, int minutes) {
    return '$prayer vakti $minutes dakika sonra';
  }

  @override
  String get currentPrayer => 'Mevcut Namaz';

  @override
  String get timeRemaining => 'Kalan Süre';

  @override
  String get hijri => 'Hicri';

  @override
  String get gregorian => 'Miladi';

  @override
  String get searchCity => 'Şehir ara...';

  @override
  String get searchDistrict => 'İlçe ara...';

  @override
  String get notificationEnabled => 'Bildirim açık';

  @override
  String get notificationDisabled => 'Bildirim kapalı';

  @override
  String get serverError => 'Sunucu hatası. Lütfen tekrar deneyin.';

  @override
  String get updateRequired => 'Uygulama güncellemesi gerekli';

  @override
  String get permissionDenied => 'Bildirim izni reddedildi';

  @override
  String get enableNotifications => 'Bildirimleri Etkinleştir';

  @override
  String get minutesBefore5 => '5 dakika önce';

  @override
  String get minutesBefore10 => '10 dakika önce';

  @override
  String get minutesBefore15 => '15 dakika önce';

  @override
  String get minutesBefore30 => '30 dakika önce';
}
