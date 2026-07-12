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

  @override
  String get sectionAppearance => 'GÖRÜNÜM';

  @override
  String get sectionLanguage => 'DİL';

  @override
  String get sectionLocation => 'KONUM';

  @override
  String get sectionReminder => 'HATIRLATMA';

  @override
  String get sectionNotifications => 'BİLDİRİMLER';

  @override
  String get sectionAbout => 'HAKKINDA';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get notSelected => 'Seçilmedi';

  @override
  String get aboutApp => 'Uygulama hakkında';

  @override
  String reminderDescription(int count) {
    return 'Her namazdan $count dakika önce bildirim alın';
  }

  @override
  String minutesShort(int count) {
    return '$count dk';
  }

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get searchHint => 'Ara...';

  @override
  String get continueButton => 'Devam';

  @override
  String get otherPrayers => 'Diğer vakitler';

  @override
  String get badgeStale => 'Eski';

  @override
  String get badgeOffline => 'Çevrimdışı';

  @override
  String get exactAlarmsDisabled =>
      'Tam zamanlı bildirimler kapalı — Etkinleştirmek için dokunun';

  @override
  String get qiblaDirection => 'Kıble Yönü';

  @override
  String get qiblaSubtitle => 'Kabe\'nin yönünü bul';

  @override
  String get verseOfTheDay => 'Günün Ayeti';

  @override
  String get cityNotSelected => 'Şehir seçilmedi';

  @override
  String get explore => 'Keşfet';

  @override
  String get calendarSubtitle => 'Aylık namaz vakitleri';

  @override
  String get hadith => 'Hadis';

  @override
  String get hadithSubtitle => 'Sahih koleksiyonları oku';

  @override
  String get hadithOfTheDay => 'GÜNÜN HADİSİ';

  @override
  String get readMore => 'Devamını oku';

  @override
  String get qibla => 'Kıble';

  @override
  String get locationPermissionNeeded =>
      'Konum iznine ihtiyaç var.\nKıble yönünü hesaplamak için izin verin.';

  @override
  String get grantPermission => 'İzin Ver';

  @override
  String get noMagnetometer => 'Bu cihazda manyetometre sensörü bulunamadı.';

  @override
  String get kaabaMecca => 'Kâbe • Mekke';

  @override
  String get kaabaDirection => 'KÂBE YÖNÜ';

  @override
  String get facingQibla => 'Kıbleye dönüyorsunuz';

  @override
  String get rotatePhone => 'Telefonu döndürün';

  @override
  String get quran => 'Kuran';

  @override
  String get quranSearchHint => 'Ara veya 2:255 yaz';

  @override
  String get surahs => 'Sureler';

  @override
  String get verses => 'Ayetler';

  @override
  String get juz => 'Cüz';

  @override
  String get continueReading => 'Kaldığın yerden devam et';

  @override
  String get connectionError => 'Bağlantı hatası.';

  @override
  String get connectionErrorCheckInternet =>
      'Bağlantı hatası.\nLütfen internet bağlantınızı kontrol edin.';

  @override
  String get connectionErrorRetry => 'Bağlantı hatası. Lütfen tekrar deneyin.';

  @override
  String get noVerseResults => 'Ayet sonucu bulunamadı.';

  @override
  String get goDirectly => 'Doğrudan git';

  @override
  String get copyArabic => 'Arapça metni kopyala';

  @override
  String get copyTranslation => 'Tercümeyi kopyala';

  @override
  String get copied => 'Kopyalandı!';

  @override
  String get removeFromFavorites => 'Favorilerden çıkar';

  @override
  String get addToFavorites => 'Favorilere ekle';

  @override
  String get loadingError => 'Yükleme hatası';

  @override
  String get favorites => 'Favoriler';

  @override
  String get noFavoritesYet => 'Henüz favori eklemediniz.';

  @override
  String get favoritesHint =>
      'Bir ayete uzun basarak favorilere ekleyebilirsiniz.';

  @override
  String get reciter => 'Okuyucu';

  @override
  String get hadithSearchHint => 'Ara (metin veya no)...';

  @override
  String get chapters => 'Bölümler';

  @override
  String get hadithsLabel => 'hadis';

  @override
  String get collectionUnavailableInLang =>
      'Bu koleksiyon seçilen dilde mevcut değil — İngilizce gösteriliyor';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String get noFavoriteHadith => 'Henüz favori hadis yok';

  @override
  String get favoriteHadithHint =>
      'Bir hadisi favorilere eklemek için ⭐ simgesine dokunun';

  @override
  String get errorTimeout =>
      'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get errorNoInternet =>
      'İnternet bağlantısı yok. Çevrimdışı modda çalışıyorsunuz.';

  @override
  String errorServer(int code) {
    return 'Sunucu hatası ($code).';
  }

  @override
  String get fontSize => 'Yazı Boyutu';

  @override
  String resumeReadingAt(int number) {
    return 'Kaldığınız yerden devam edin · #$number';
  }

  @override
  String get favorite => 'Favori';

  @override
  String get favorited => 'Favoride';

  @override
  String get copy => 'Kopyala';

  @override
  String get share => 'Paylaş';

  @override
  String get previous => 'Önceki';

  @override
  String get next => 'Sonraki';

  @override
  String get dataSource => 'Veri kaynağı';

  @override
  String get developer => 'Geliştirici';

  @override
  String get contact => 'İletişim';

  @override
  String notifReminderTitle(String prayer) {
    return '🕌 $prayer Vakti';
  }

  @override
  String notifReminderBody(String prayer, int minutes) {
    return '$prayer namazına $minutes dakika kaldı';
  }

  @override
  String notifAtTimeTitle(String prayer) {
    return '🕌 $prayer Vakti Girdi';
  }

  @override
  String notifAtTimeBody(String prayer) {
    return '$prayer namazının vakti geldi';
  }
}
