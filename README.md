<div align="center">

<table><tr><td bgcolor="#0A1F14" align="center" width="160">
<img src="assets/Logo.png" alt="Namaz Vakti Logo" width="120"/>
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

**Namaz Vakti**, Türkiye'de yaşayan Müslümanların Diyanet İşleri Başkanlığı tarafından yayımlanan resmi namaz vakitlerini takip etmelerini ve her namaz için bildirim almalarını sağlayan bir Android uygulamasıdır.

### Özellikler

- **Resmi Diyanet Vakitleri** — Türkiye'nin tüm il ve ilçeleri için API üzerinden alınan veriler
- **Akıllı Bildirimler** — Her namaz için 10, 20 veya 30 dakika önce hatırlatma + tam vakitte bildirim
- **Şehir Seçimi** — Türkiye'nin tüm il ve ilçeleri mevcut
- **Kıble Pusulası** — GPS konumundan Kabe yönünü gösteren canlı manyetik pusula
- **Karanlık / Aydınlık Tema** — İslami gradyan ile uyarlanabilir tema
- **Aylık Takvim** — Hicri tarih dahil aylık namaz vakitleri görünümü
- **Çevrimdışı Önbellek** — İnternet bağlantısı olmadan erişim için veriler önbelleğe alınır
- **Veri Tazeliği Göstergesi** — Verilerin güncel, eski veya çevrimdışı olduğunu belirten rozet
- **Kuran-ı Kerim** — Türkçe, İngilizce ve Fransızca meali ile ayet görüntüleme; Cüz navigasyonu; Favoriler; kaldığın yeri devam ettir; ayarlanabilir font boyutu

### Kurulum

```bash
git clone https://github.com/Ismael-sang98/Muslim-App.git
cd namaz_vakti
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Mimari

```
lib/
├── core/
│   ├── api/              # HTTP servisi (Dio) — Diyanet API
│   ├── hive/             # Veri modelleri ve yerel depolama (Hive)
│   ├── notifications/    # Bildirim servisi (flutter_local_notifications)
│   ├── theme/            # Açık/koyu temalar (AppTheme)
│   └── widgets/          # Paylaşılan widget'lar (GradientScaffold vb.)
├── features/
│   ├── home/             # Ana ekran — sonraki namaz, geri sayım
│   ├── quran/            # Kuran-ı Kerim — sureler, ayetler, favoriler
│   ├── qibla/            # Kıble pusulası — GPS + manyetometre
│   ├── calendar/         # Aylık takvim
│   ├── settings/         # Ayarlar — şehir, tema, bildirimler
│   └── onboarding/       # İlk başlatma — şehir seçimi + izinler
└── main.dart
```

**State yönetimi:** Riverpod · **Yerel depolama:** Hive · **Navigasyon:** Özel alt gezinme çubuğu

### Android İzinleri

| İzin | Neden |
|---|---|
| `INTERNET` | API üzerinden vakitleri almak için |
| `RECEIVE_BOOT_COMPLETED` | Yeniden başlatma sonrası bildirimleri yeniden planlamak için |
| `POST_NOTIFICATIONS` | Bildirimleri göstermek için (Android 13+) |
| `USE_EXACT_ALARM` | Bildirimler için kesin alarmlar |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Arka planda bildirim güvenilirliği |

---

## English

### Overview

**Namaz Vakti** is an Android application built with Flutter that allows Muslims living in Turkey to check official prayer times published by the Diyanet İşleri Başkanlığı (Presidency of Religious Affairs), and receive notifications before each prayer.

### Features

- **Official Diyanet Prayer Times** — Data fetched via API for all provinces and districts in Turkey
- **Smart Notifications** — Configurable reminder 10, 20 or 30 minutes before each prayer + notification at the exact prayer time
- **City Selection** — All provinces and districts in Turkey available
- **Qibla Compass** — Live magnetic compass showing the direction of the Kaaba based on GPS location
- **Dark / Light Theme** — Adaptive theme with Islamic gradient
- **Monthly Calendar** — Full month prayer times view with Hijri date
- **Offline Cache** — Data is cached for access without an internet connection
- **Freshness Indicator** — Badge indicating whether data is up-to-date, stale or offline
- **Holy Quran** — Verse display with Turkish, English and French translations; Juz navigation; Favorites; resume reading; adjustable font size

### Installation

```bash
git clone https://github.com/Ismael-sang98/Muslim-App.git
cd namaz_vakti
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Architecture

```
lib/
├── core/
│   ├── api/              # HTTP service (Dio) — Diyanet API
│   ├── hive/             # Data models and local storage (Hive)
│   ├── notifications/    # Notification service (flutter_local_notifications)
│   ├── theme/            # Light/dark themes (AppTheme)
│   └── widgets/          # Shared widgets (GradientScaffold, etc.)
├── features/
│   ├── home/             # Main screen — next prayer, countdown
│   ├── quran/            # Holy Quran — surahs, verses, favorites
│   ├── qibla/            # Qibla compass — GPS + magnetometer
│   ├── calendar/         # Monthly calendar
│   ├── settings/         # Settings — city, theme, notifications
│   └── onboarding/       # First launch — city selection + permissions
└── main.dart
```

**State management:** Riverpod · **Local storage:** Hive · **Navigation:** Custom bottom navigation bar

### Tech Stack

| Technology | Usage |
|---|---|
| [Flutter](https://flutter.dev) | Cross-platform UI framework |
| [Riverpod](https://riverpod.dev) | State management |
| [Hive](https://pub.dev/packages/hive) | Local database |
| [Dio](https://pub.dev/packages/dio) | HTTP client |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Scheduled notifications |
| [timezone](https://pub.dev/packages/timezone) | Timezone handling (Europe/Istanbul) |
| [geolocator](https://pub.dev/packages/geolocator) | GPS position for Qibla calculation |
| [flutter_compass](https://pub.dev/packages/flutter_compass) | Magnetometer heading stream |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Typography (Poppins) |
| [Scheherazade New](https://software.sil.org/scheherazade/) | Arabic Quranic font (bundled) |
| [flutter_animate](https://pub.dev/packages/flutter_animate) | UI animations |

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
| `INTERNET` | Fetching prayer times via API |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notifications after device reboot |
| `POST_NOTIFICATIONS` | Display notifications (Android 13+) |
| `USE_EXACT_ALARM` | Precise alarms for notifications |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Background notification reliability |

---

## Français

### Aperçu

**Namaz Vakti** est une application mobile Android développée en Flutter permettant aux musulmans résidant en Turquie de consulter les horaires de prière officiels publiés par la Diyanet İşleri Başkanlığı (Présidence des Affaires Religieuses), et de recevoir des notifications avant chaque prière.

### Fonctionnalités

- **Horaires officiels Diyanet** — données récupérées via API pour toutes les provinces et districts de Turquie
- **Notifications intelligentes** — rappel configurable 10, 20 ou 30 minutes avant chaque prière + notification à l'heure exacte
- **Sélection de la ville** — toutes les provinces et districts de Turquie disponibles
- **Boussole Qibla** — boussole magnétique en temps réel indiquant la direction de la Kaaba depuis la position GPS
- **Mode sombre / clair** — thème adaptatif avec gradient islamique
- **Calendrier mensuel** — vue calendrier avec les horaires du mois complet et date hijri
- **Cache hors-ligne** — les données sont mises en cache pour un accès sans connexion
- **Indicateur de fraîcheur** — badge indiquant si les données sont à jour, récentes ou hors-ligne
- **Coran** — affichage des versets avec traductions turque, anglaise et française ; navigation par Juz ; favoris ; reprise de lecture ; taille de police réglable

### Installation

```bash
git clone https://github.com/Ismael-sang98/Muslim-App.git
cd namaz_vakti
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Architecture

```
lib/
├── core/
│   ├── api/              # Service HTTP (Dio) — API Diyanet
│   ├── hive/             # Modèles de données et persistance locale (Hive)
│   ├── notifications/    # Service de notifications (flutter_local_notifications)
│   ├── theme/            # Thèmes clair/sombre (AppTheme)
│   └── widgets/          # Widgets partagés (GradientScaffold, etc.)
├── features/
│   ├── home/             # Écran principal — prochaine prière, countdown
│   ├── quran/            # Coran — sourates, versets, favoris
│   ├── qibla/            # Boussole Qibla — GPS + magnétomètre
│   ├── calendar/         # Calendrier mensuel
│   ├── settings/         # Paramètres — ville, thème, notifications
│   └── onboarding/       # Premier lancement — sélection ville + permissions
└── main.dart
```

**State management :** Riverpod · **Persistance :** Hive · **Navigation :** Bottom navigation bar custom

### Stack technique

| Technologie | Usage |
|---|---|
| [Flutter](https://flutter.dev) | Framework UI cross-platform |
| [Riverpod](https://riverpod.dev) | State management |
| [Hive](https://pub.dev/packages/hive) | Base de données locale |
| [Dio](https://pub.dev/packages/dio) | Client HTTP |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Notifications planifiées |
| [timezone](https://pub.dev/packages/timezone) | Gestion du fuseau horaire (Europe/Istanbul) |
| [geolocator](https://pub.dev/packages/geolocator) | Position GPS pour le calcul de la Qibla |
| [flutter_compass](https://pub.dev/packages/flutter_compass) | Flux de cap magnétomètre |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Typographies (Poppins) |
| [Scheherazade New](https://software.sil.org/scheherazade/) | Police arabe coranique (bundlée) |
| [flutter_animate](https://pub.dev/packages/flutter_animate) | Animations d'interface |

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
| `INTERNET` | Récupération des horaires via API |
| `RECEIVE_BOOT_COMPLETED` | Replanification des notifications après redémarrage |
| `POST_NOTIFICATIONS` | Affichage des notifications (Android 13+) |
| `USE_EXACT_ALARM` | Alarmes précises pour les notifications |
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
