<div align="center">

<table><tr><td bgcolor="#0A1F14" align="center" width="160">
<img src="assets/Logo.png" alt="Muslim App Logo" width="120"/>
</td></tr></table>

# Muslim App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-API%2021+-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Ismael-sang98/Muslim-App?color=orange&label=Version)](https://github.com/Ismael-sang98/Muslim-App/releases/latest)

**[Türkçe](#türkçe) · [English](#english) · [Français](#français)**

### Télécharger / Download / İndir

[![Télécharger APK](https://img.shields.io/badge/Télécharger%20APK-Dernière%20version-2EA85D?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Ismael-sang98/Muslim-App/releases/latest)

</div>

---

## Türkçe

### Genel Bakış

**Muslim App**, Türkiye'de yaşayan Müslümanlar için geliştirilmiş kapsamlı bir Android uygulamasıdır. Diyanet İşleri Başkanlığı'nın resmi namaz vakitlerini takip etmenizi, Kuran-ı Kerim ve hadis okumanızı ve kıble yönünü bulmanızı sağlar. Arayüz tamamen **Türkçe, İngilizce ve Fransızca** olarak sunulur.

### Özellikler

#### 🕌 Namaz Vakitleri
- **Resmi Diyanet Vakitleri** — Türkiye'nin tüm il ve ilçeleri için API üzerinden alınan veriler
- **Akıllı Bildirimler** — Her namaz için 10, 20 veya 30 dakika önce hatırlatma + tam vakitte bildirim
- **Geri Sayım** — Sonraki namaza kalan süreyi gerçek zamanlı gösteren sayaç
- **Şehir Seçimi** — Türkiye'nin tüm il ve ilçeleri mevcut
- **Çevrimdışı Önbellek** — İnternet bağlantısı olmadan erişim için veriler önbelleğe alınır

#### 🏠 Ana Ekran Widget'ları
- **Sonraki Namaz Widget'ı** — telefon ana ekranında sonraki namaz + saat + şehir
- **Tüm Vakitler Widget'ı** — günün 6 vakti, sonraki vakit turuncu ile vurgulanır
- **Kendi Kendine Güncelleme** — uygulama kapalıyken bile yenilenir; dokununca uygulama açılır

#### 📖 Kuran-ı Kerim
- **114 Sure** — Tam Kuran metni Arapça (Scheherazade New) ile
- **Çok Dilli Mealler** — Türkçe, İngilizce ve Fransızca meal desteği
- **Ayet Sesli Okuma** — Seçilen sure ve ayetleri kari sesiyle dinleme
- **Tam Ayet Navigasyonu** — Arama, favoriler ve günün ayeti doğrudan hedef ayete yönlendirir
- **Kaldığın Yere Devam** — Kapattığın sure ve ayetten okumaya devam et
- **Favoriler** — Beğenilen ayetleri kaydet, tek tıkla geri dön
- **Günün Ayeti** — Her gün ana ekranda farklı bir ayet
- **Cüz Navigasyonu** — 30 cüz üzerinden gezinme
- **Ayarlanabilir Font** — Arapça metin boyutunu isteğine göre ayarla

#### 📚 Hadis
- **Sahih Koleksiyonlar** — Buhari, Müslim, Ebu Davud, İbn Mace, Nesai, Tirmizi, Kudsi, Nevevi (fawazahmed0/hadith-api)
- **Çok Dilli** — Türkçe, İngilizce, Fransızca; bir koleksiyon o dilde yoksa otomatik İngilizce'ye geçiş
- **Arama** — metne veya hadis numarasına göre
- **Bölüm (Kitâb) Navigasyonu** — bölüm başlıkları, bölüm seçici ve her hadiste kitâb adı
- **Sıhhat Derecesi** — mevcutsa Sahih/Hasen rozeti
- **Favoriler, Kopyala, Paylaş**
- **Tam Ekran Okuma** — tek hadis görünümü, sağa/sola kaydırarak gezinme
- **Kaldığın Yere Devam** — her koleksiyon için son okunan hadis
- **Günün Hadisi** — Keşfet ekranında her gün farklı bir hadis
- **Ayarlanabilir Font + Çevrimdışı Önbellek**

#### 🌍 Çok Dilli Arayüz
- **Tam Türkçe / İngilizce / Fransızca** — tüm arayüz, Kuran mealleri, hadisler ve bildirimler
- **İlk açılışta cihaz diline uyum** + Ayarlar'dan istediğin zaman değiştir
- **Keşfet Sekmesi** — Takvim ve Hadis'i tek bir merkezden aç

#### 🧭 Kıble Pusulası
- **Canlı Manyetik Pusula** — GPS konumundan Kabe yönünü gösteren animasyonlu pusula
- **Hizalama Geri Bildirimi** — Kıbleye döndüğünde titreşim ve yeşil parlama efekti
- **Paysage / Dikey Mod** — Her ekran boyutuna uyumlu duyarlı tasarım

#### 📅 Takvim
- **Aylık Görünüm** — Tüm ay namaz vakitlerini tek ekranda göster
- **Hicri Tarih** — Miladi tarihin yanında Hicri tarih bilgisi

#### ⚙️ Ayarlar
- **Dil Seçimi** — Türkçe / İngilizce / Fransızca (arayüz + içerik)
- **Karanlık / Aydınlık / Sistem Teması** — İkon tabanlı tema seçici
- **Namaza Özel Bildirimler** — Her namaz için ayrı açma/kapama; her birinin rengi farklı
- **Şehir Güncelleme** — İl ve ilçeyi istediğin zaman değiştir

### Kurulum

```bash
git clone https://github.com/Ismael-sang98/Muslim-App.git
cd namaz_vakti
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

> ℹ️ Kuran API anahtarı için `lib/core/config/quran_config.dart` dosyasını oluşturun (`.gitignore` kapsamında).

### Mimari

```
lib/
├── core/
│   ├── api/              # HTTP servisi (Dio) — Diyanet + Kuran + Hadis API
│   ├── config/           # API anahtarları (gitignore'da)
│   ├── hive/             # Veri modelleri ve yerel depolama (Hive)
│   ├── notifications/    # Bildirim servisi (çok dilli)
│   ├── theme/            # Açık/koyu temalar (AppTheme)
│   ├── utils/            # Hicri dönüştürücü, yerelleştirilmiş adlar
│   └── widgets/          # Paylaşılan widget'lar
├── features/
│   ├── home/             # Ana ekran — sonraki namaz, geri sayım, günün ayeti
│   ├── hub/              # Keşfet merkezi — Takvim + Hadis
│   ├── quran/            # Kuran-ı Kerim — sureler, ayetler, arama, favoriler, ses
│   ├── hadith/           # Hadis — koleksiyonlar, bölümler, arama, favoriler, detay
│   ├── qibla/            # Kıble pusulası — GPS + manyetometre + titreşim
│   ├── calendar/         # Aylık takvim (Hicri + Miladi)
│   ├── settings/         # Ayarlar — dil, şehir, tema, bildirimler
│   └── onboarding/       # İlk başlatma — şehir seçimi + izinler
├── l10n/                 # Yerelleştirme (TR/EN/FR .arb)
└── main.dart
```

**State yönetimi:** Riverpod · **Yerel depolama:** Hive · **Yerelleştirme:** flutter_localizations · **Navigasyon:** Özel alt gezinme çubuğu

### Testler

```bash
flutter test
```

- **Hadis API servisi** — `.min.json → .json` fallback, timeout, hata yönetimi, dil repli, dereceler ve bölümlerin ayrıştırılması (mocktail)
- **Güvenilirlik** — Hicri dönüşümü, namaz vakti ayrıştırma, yerelleştirme yardımcıları

### Android İzinleri

| İzin | Neden |
|---|---|
| `INTERNET` | API üzerinden vakitleri ve Kuran verilerini almak için |
| `ACCESS_FINE_LOCATION` | Kıble yönü hesabı için GPS konumu |
| `VIBRATE` | Kıble hizalandığında titreşim |
| `RECEIVE_BOOT_COMPLETED` | Yeniden başlatma sonrası bildirimleri yeniden planlamak için |
| `POST_NOTIFICATIONS` | Bildirimleri göstermek için (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Bildirimler için kesin alarmlar |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Arka planda bildirim güvenilirliği |

---

## English

### Overview

**Muslim App** is a comprehensive Android application built with Flutter for Muslims living in Turkey. It provides official Diyanet prayer times, Quran and hadith reading with audio playback, and a live Qibla compass. The entire interface is available in **Turkish, English and French**.

### Features

#### 🕌 Prayer Times
- **Official Diyanet Prayer Times** — Data fetched via API for all provinces and districts in Turkey
- **Smart Notifications** — Configurable reminder 10, 20 or 30 minutes before each prayer + notification at the exact time
- **Live Countdown** — Real-time timer to the next prayer
- **City Selection** — All provinces and districts in Turkey available
- **Offline Cache** — Data cached for access without an internet connection

#### 🏠 Home-screen Widgets
- **Next Prayer Widget** — next prayer + time + city on your phone's home screen
- **All Times Widget** — the day's six prayer times, the next one highlighted in orange
- **Self-updating** — refreshes on its own even when the app is closed; tap to open the app

#### 📖 Holy Quran
- **114 Surahs** — Full Quran in Arabic (Scheherazade New font)
- **Multi-language Translations** — Turkish, English and French
- **Verse Audio Playback** — Listen to individual verses with reciter audio
- **Precise Verse Navigation** — Search (e.g. "2:255"), favorites and daily verse all scroll directly to the target verse
- **Resume Reading** — Continues from the exact surah and verse where you left off
- **Favorites** — Save verses and return to them with one tap
- **Verse of the Day** — A different verse displayed on the home screen each day
- **Juz Navigation** — Browse all 30 Juz
- **Adjustable Font** — Resize Arabic text to your preference

#### 📚 Hadith
- **Authentic Collections** — Bukhari, Muslim, Abu Dawud, Ibn Majah, Nasa'i, Tirmidhi, Qudsi, Nawawi (fawazahmed0/hadith-api)
- **Multilingual** — Turkish, English, French; automatic English fallback when a collection is unavailable in a language
- **Search** — by text or hadith number
- **Chapter (Kitāb) Navigation** — chapter headers, a chapter picker, and the chapter name on each hadith
- **Authenticity Grade** — Sahih/Hasan badge when available
- **Favorites, Copy, Share**
- **Full-screen Reading** — single-hadith view with swipe navigation
- **Resume Reading** — last read hadith per collection
- **Hadith of the Day** — a different hadith each day on the Explore screen
- **Adjustable Font + Offline Cache**

#### 🌍 Multilingual Interface
- **Full Turkish / English / French** — the entire UI, Quran translations, hadiths and notifications
- **Follows the device language on first launch** + change anytime in Settings
- **Explore Tab** — open Calendar and Hadith from a single hub

#### 🧭 Qibla Compass
- **Live Magnetic Compass** — Animated compass pointing to the Kaaba from your GPS position
- **Alignment Feedback** — Haptic vibration + green glow when facing the Qibla
- **Responsive Layout** — Adapts to portrait and landscape orientations

#### 📅 Calendar
- **Monthly View** — Full month of prayer times at a glance
- **Hijri Date** — Displayed alongside the Gregorian date

#### ⚙️ Settings
- **Language Selection** — Turkish / English / French (interface + content)
- **Dark / Light / System Theme** — Icon-based segmented theme selector
- **Per-prayer Notifications** — Individual toggle per prayer, each with its own accent color
- **City Update** — Change province and district at any time

### Installation

```bash
git clone https://github.com/Ismael-sang98/Muslim-App.git
cd namaz_vakti
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

> ℹ️ Create `lib/core/config/quran_config.dart` with your Quran API key (excluded from version control via `.gitignore`).

### Architecture

```
lib/
├── core/
│   ├── api/              # HTTP service (Dio) — Diyanet + Quran + Hadith API
│   ├── config/           # API keys (gitignored)
│   ├── hive/             # Data models and local storage (Hive)
│   ├── notifications/    # Notification service (localized)
│   ├── theme/            # Light/dark themes (AppTheme)
│   ├── utils/            # Hijri converter, localized names
│   └── widgets/          # Shared widgets
├── features/
│   ├── home/             # Main screen — next prayer, countdown, verse of the day
│   ├── hub/              # Explore hub — Calendar + Hadith
│   ├── quran/            # Holy Quran — surahs, verses, search, favorites, audio
│   ├── hadith/           # Hadith — collections, chapters, search, favorites, detail
│   ├── qibla/            # Qibla compass — GPS + magnetometer + haptics
│   ├── calendar/         # Monthly calendar (Hijri + Gregorian)
│   ├── settings/         # Settings — language, city, theme, notifications
│   └── onboarding/       # First launch — city selection + permissions
├── l10n/                 # Localizations (TR/EN/FR .arb)
└── main.dart
```

**State management:** Riverpod · **Local storage:** Hive · **Localization:** flutter_localizations · **Navigation:** Custom bottom navigation bar

### Testing

```bash
flutter test
```

- **Hadith API service** — `.min.json → .json` fallback, timeout, error handling, language fallback, grade & chapter parsing (mocktail)
- **Reliability** — Hijri conversion, prayer-time parsing, localization utilities

### Tech Stack

| Technology | Usage |
|---|---|
| [Flutter](https://flutter.dev) | Cross-platform UI framework |
| [Riverpod](https://riverpod.dev) | State management |
| [Hive](https://pub.dev/packages/hive) | Local database |
| [Dio](https://pub.dev/packages/dio) | HTTP client |
| [flutter_localizations + intl](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) | Internationalization (TR/EN/FR) |
| [just_audio](https://pub.dev/packages/just_audio) | Verse-by-verse audio playback |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Scheduled (localized) notifications |
| [home_widget](https://pub.dev/packages/home_widget) | Home-screen widgets (Android) |
| [timezone](https://pub.dev/packages/timezone) | Timezone handling (Europe/Istanbul) |
| [geolocator](https://pub.dev/packages/geolocator) | GPS position for Qibla calculation |
| [flutter_compass](https://pub.dev/packages/flutter_compass) | Magnetometer heading stream |
| [share_plus](https://pub.dev/packages/share_plus) | Sharing hadiths and verses |
| [shimmer](https://pub.dev/packages/shimmer) | Skeleton loading placeholders |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Typography (Poppins) |
| [Scheherazade New](https://software.sil.org/scheherazade/) | Arabic Quranic font (bundled) |
| [flutter_animate](https://pub.dev/packages/flutter_animate) | UI animations |
| [mocktail](https://pub.dev/packages/mocktail) | Unit test mocking (dev) |

### Production Build (Android)

**1. Generate the signing keystore (once)**
```bash
keytool -genkey -v -keystore ~/muslim_release.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias muslim
```

**2. Configure signing** — Copy `muslim_release.jks` to `android/app/`, then create `android/key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=muslim
storeFile=muslim_release.jks
```
> ⚠️ Never commit `key.properties` or `*.jks` — already excluded via `.gitignore`

**3. Build the APK**
```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

### Android Permissions

| Permission | Reason |
|---|---|
| `INTERNET` | Fetching prayer times and Quran data via API |
| `ACCESS_FINE_LOCATION` | GPS location for Qibla direction |
| `VIBRATE` | Haptic feedback when aligned with Qibla |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notifications after device reboot |
| `POST_NOTIFICATIONS` | Display notifications (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Precise alarms for notifications |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Background notification reliability |

---

## Français

### Aperçu

**Muslim App** est une application Android complète développée en Flutter pour les musulmans résidant en Turquie. Elle regroupe les horaires de prière officiels Diyanet, la lecture du Coran et des hadiths avec audio, et une boussole Qibla en temps réel. L'interface est entièrement disponible en **turc, anglais et français**.

### Fonctionnalités

#### 🕌 Horaires de prière
- **Horaires officiels Diyanet** — données récupérées via API pour toutes les provinces et districts de Turquie
- **Notifications intelligentes** — rappel configurable 10, 20 ou 30 minutes avant chaque prière + notification à l'heure exacte
- **Compte à rebours en direct** — minuterie en temps réel jusqu'à la prochaine prière
- **Sélection de la ville** — toutes les provinces et districts de Turquie disponibles
- **Cache hors-ligne** — les données sont mises en cache pour un accès sans connexion

#### 🏠 Widgets d'écran d'accueil
- **Widget Prochaine prière** — prochaine prière + heure + ville sur l'écran d'accueil du téléphone
- **Widget Toutes les prières** — les 6 vakit du jour, la prochaine surlignée en orange
- **Auto-mise à jour** — se rafraîchit tout seul même app fermée ; un tap ouvre l'app

#### 📖 Coran
- **114 sourates** — texte arabe intégral (police Scheherazade New)
- **Traductions multilingues** — turc, anglais et français
- **Lecture audio des versets** — écoutez les versets avec la voix d'un récitant
- **Navigation précise vers un verset** — la recherche (ex. « 2:255 »), les favoris et le verset du jour défilent directement jusqu'au verset cible
- **Reprendre la lecture** — continue exactement depuis la sourate et le verset où vous vous étiez arrêté
- **Favoris** — sauvegardez des versets et revenez-y en un tap
- **Verset du jour** — un verset différent affiché chaque jour sur l'écran d'accueil
- **Navigation par Juz** — parcourez les 30 Juz
- **Police ajustable** — redimensionnez le texte arabe à votre convenance

#### 📚 Hadith
- **Recueils authentiques** — Bukhari, Muslim, Abu Dawud, Ibn Majah, Nasa'i, Tirmidhi, Qudsi, Nawawi (fawazahmed0/hadith-api)
- **Multilingue** — turc, anglais, français ; repli automatique vers l'anglais si un recueil est indisponible dans une langue
- **Recherche** — par texte ou numéro de hadith
- **Navigation par chapitre (Kitāb)** — en-têtes de chapitre, sélecteur de chapitre, et nom du chapitre sur chaque hadith
- **Grade d'authenticité** — badge Sahih/Hasan si disponible
- **Favoris, copier, partager**
- **Lecture plein écran** — vue d'un seul hadith avec navigation par swipe
- **Reprendre la lecture** — dernier hadith lu par recueil
- **Hadith du jour** — un hadith différent chaque jour sur l'écran Découvrir
- **Police ajustable + cache hors-ligne**

#### 🌍 Interface multilingue
- **Turc / anglais / français complet** — toute l'UI, les traductions du Coran, les hadiths et les notifications
- **Suit la langue de l'appareil au premier lancement** + modifiable à tout moment dans les Paramètres
- **Onglet Découvrir** — ouvrez le Calendrier et les Hadiths depuis un hub unique

#### 🧭 Boussole Qibla
- **Boussole magnétique en direct** — boussole animée pointant vers la Kaaba depuis votre position GPS
- **Retour haptique** — vibration + halo vert lorsque vous êtes orienté vers la Qibla
- **Layout adaptatif** — fonctionne en portrait et paysage

#### 📅 Calendrier
- **Vue mensuelle** — tous les horaires du mois en un seul écran
- **Date hijri** — affichée aux côtés de la date grégorienne

#### ⚙️ Paramètres
- **Choix de la langue** — turc / anglais / français (interface + contenu)
- **Thème sombre / clair / système** — sélecteur de thème avec icônes
- **Notifications par prière** — bascule individuelle par prière, chacune avec sa propre couleur
- **Mise à jour de la ville** — changez province et district à tout moment

### Installation

```bash
git clone https://github.com/Ismael-sang98/Muslim-App.git
cd namaz_vakti
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

> ℹ️ Créez `lib/core/config/quran_config.dart` avec votre clé API Coran (exclu du versionnement via `.gitignore`).

### Architecture

```
lib/
├── core/
│   ├── api/              # Service HTTP (Dio) — API Diyanet + Coran + Hadith
│   ├── config/           # Clés API (gitignored)
│   ├── hive/             # Modèles de données et persistance locale (Hive)
│   ├── notifications/    # Service de notifications (localisé)
│   ├── theme/            # Thèmes clair/sombre (AppTheme)
│   ├── utils/            # Convertisseur hijri, noms localisés
│   └── widgets/          # Widgets partagés
├── features/
│   ├── home/             # Écran principal — prochaine prière, countdown, verset du jour
│   ├── hub/              # Hub Découvrir — Calendrier + Hadith
│   ├── quran/            # Coran — sourates, versets, recherche, favoris, audio
│   ├── hadith/           # Hadith — recueils, chapitres, recherche, favoris, détail
│   ├── qibla/            # Boussole Qibla — GPS + magnétomètre + haptique
│   ├── calendar/         # Calendrier mensuel (Hijri + Grégorien)
│   ├── settings/         # Paramètres — langue, ville, thème, notifications
│   └── onboarding/       # Premier lancement — sélection ville + permissions
├── l10n/                 # Localisation (TR/EN/FR .arb)
└── main.dart
```

**State management :** Riverpod · **Persistance :** Hive · **Localisation :** flutter_localizations · **Navigation :** Bottom navigation bar custom

### Tests

```bash
flutter test
```

- **Service API Hadith** — repli `.min.json → .json`, timeout, gestion d'erreurs, repli de langue, parsing des grades et chapitres (mocktail)
- **Fiabilité** — conversion hijri, parsing des horaires de prière, utilitaires de localisation

### Stack technique

| Technologie | Usage |
|---|---|
| [Flutter](https://flutter.dev) | Framework UI cross-platform |
| [Riverpod](https://riverpod.dev) | State management |
| [Hive](https://pub.dev/packages/hive) | Base de données locale |
| [Dio](https://pub.dev/packages/dio) | Client HTTP |
| [flutter_localizations + intl](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) | Internationalisation (TR/EN/FR) |
| [just_audio](https://pub.dev/packages/just_audio) | Lecture audio verset par verset |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Notifications planifiées (localisées) |
| [home_widget](https://pub.dev/packages/home_widget) | Widgets d'écran d'accueil (Android) |
| [timezone](https://pub.dev/packages/timezone) | Gestion du fuseau horaire (Europe/Istanbul) |
| [geolocator](https://pub.dev/packages/geolocator) | Position GPS pour le calcul de la Qibla |
| [flutter_compass](https://pub.dev/packages/flutter_compass) | Flux de cap magnétomètre |
| [share_plus](https://pub.dev/packages/share_plus) | Partage des hadiths et versets |
| [shimmer](https://pub.dev/packages/shimmer) | Squelettes de chargement |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Typographies (Poppins) |
| [Scheherazade New](https://software.sil.org/scheherazade/) | Police arabe coranique (bundlée) |
| [flutter_animate](https://pub.dev/packages/flutter_animate) | Animations d'interface |
| [mocktail](https://pub.dev/packages/mocktail) | Mocking pour les tests (dev) |

### Build de production (Android)

**1. Générer le keystore de signature (une seule fois)**
```bash
keytool -genkey -v -keystore ~/muslim_release.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias muslim
```

**2. Configurer la signature** — Copier `muslim_release.jks` dans `android/app/`, puis créer `android/key.properties` :
```properties
storePassword=VOTRE_MOT_DE_PASSE
keyPassword=VOTRE_MOT_DE_PASSE
keyAlias=muslim
storeFile=muslim_release.jks
```
> ⚠️ Ne jamais committer `key.properties` ni `*.jks` — déjà exclus via `.gitignore`

**3. Builder l'APK**
```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

### Permissions Android

| Permission | Raison |
|---|---|
| `INTERNET` | Récupération des horaires et des données Coran via API |
| `ACCESS_FINE_LOCATION` | Position GPS pour la direction Qibla |
| `VIBRATE` | Retour haptique quand la Qibla est alignée |
| `RECEIVE_BOOT_COMPLETED` | Replanification des notifications après redémarrage |
| `POST_NOTIFICATIONS` | Affichage des notifications (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Alarmes précises pour les notifications |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Fiabilité des notifications en arrière-plan |

---

## Licence / License / Lisans

Ce projet est distribué sous licence [MIT](LICENSE).  
This project is licensed under the [MIT License](LICENSE).  
Bu proje [MIT Lisansı](LICENSE) kapsamında dağıtılmaktadır.

---

<div align="center">
Développé par · Developed by · Geliştiren : <strong>Ismael Sanogo</strong>
</div>
