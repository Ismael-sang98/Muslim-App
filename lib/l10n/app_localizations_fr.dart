// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Horaires de Prière';

  @override
  String get nextPrayer => 'Prochaine Prière';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get settings => 'Paramètres';

  @override
  String get city => 'Ville';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminderBefore => 'minutes avant rappel';

  @override
  String get imsak => 'Imsak (Fajr)';

  @override
  String get gunes => 'Lever du soleil';

  @override
  String get ogle => 'Dhuhr';

  @override
  String get ikindi => 'Asr';

  @override
  String get aksam => 'Maghrib';

  @override
  String get yatsi => 'Isha';

  @override
  String get offlineMode => 'Mode Hors-ligne';

  @override
  String get refreshData => 'Rafraîchir les données';

  @override
  String get selectCity => 'Sélectionner une ville';

  @override
  String get selectProvince => 'Sélectionner une province';

  @override
  String get selectDistrict => 'Sélectionner un district';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get lightMode => 'Mode Clair';

  @override
  String get systemMode => 'Mode Système';

  @override
  String prayerTime(String prayer) {
    return 'Heure de $prayer';
  }

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String get dataStale => 'Les données peuvent être périmées';

  @override
  String get noConnection => 'Pas de connexion internet';

  @override
  String get retry => 'Réessayer';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get chooseLanguage => 'Choisissez votre langue';

  @override
  String get chooseCity => 'Choisissez votre ville';

  @override
  String get startApp => 'Commencer';

  @override
  String get calendar => 'Calendrier';

  @override
  String get hijriDate => 'Date Hégirienne';

  @override
  String get province => 'Province';

  @override
  String get district => 'District';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get home => 'Accueil';

  @override
  String get reminderDelay => 'Délai de rappel';

  @override
  String get notificationSound => 'Son de notification';

  @override
  String get theme => 'Thème';

  @override
  String get about => 'À propos';

  @override
  String get noDataOffline =>
      'Pas de données hors-ligne. Veuillez vérifier votre connexion internet.';

  @override
  String get dataUpdated => 'Données mises à jour';

  @override
  String prayerReminder(String prayer, int minutes) {
    return 'Prière $prayer dans $minutes minutes';
  }

  @override
  String get currentPrayer => 'Prière en cours';

  @override
  String get timeRemaining => 'Temps restant';

  @override
  String get hijri => 'Hégire';

  @override
  String get gregorian => 'Grégorien';

  @override
  String get searchCity => 'Rechercher une ville...';

  @override
  String get searchDistrict => 'Rechercher un district...';

  @override
  String get notificationEnabled => 'Notification activée';

  @override
  String get notificationDisabled => 'Notification désactivée';

  @override
  String get serverError => 'Erreur serveur. Veuillez réessayer.';

  @override
  String get updateRequired => 'Mise à jour de l\'application requise';

  @override
  String get permissionDenied => 'Permission de notification refusée';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get minutesBefore5 => '5 minutes avant';

  @override
  String get minutesBefore10 => '10 minutes avant';

  @override
  String get minutesBefore15 => '15 minutes avant';

  @override
  String get minutesBefore30 => '30 minutes avant';

  @override
  String get sectionAppearance => 'APPARENCE';

  @override
  String get sectionLanguage => 'LANGUE';

  @override
  String get sectionLocation => 'EMPLACEMENT';

  @override
  String get sectionReminder => 'RAPPEL';

  @override
  String get sectionNotifications => 'NOTIFICATIONS';

  @override
  String get sectionAbout => 'À PROPOS';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get notSelected => 'Non sélectionné';

  @override
  String get aboutApp => 'À propos de l\'application';

  @override
  String reminderDescription(int count) {
    return 'Recevez une notification $count minutes avant chaque prière';
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
  String get searchHint => 'Rechercher...';

  @override
  String get continueButton => 'Continuer';

  @override
  String get otherPrayers => 'Autres prières';

  @override
  String get badgeStale => 'Ancien';

  @override
  String get badgeOffline => 'Hors ligne';

  @override
  String get exactAlarmsDisabled =>
      'Notifications exactes désactivées — Appuyez pour activer';

  @override
  String get qiblaDirection => 'Direction de la Qibla';

  @override
  String get qiblaSubtitle => 'Trouvez la direction de la Kaaba';

  @override
  String get verseOfTheDay => 'Verset du jour';

  @override
  String get cityNotSelected => 'Aucune ville sélectionnée';

  @override
  String get explore => 'Découvrir';

  @override
  String get calendarSubtitle => 'Horaires de prière mensuels';

  @override
  String get hadith => 'Hadith';

  @override
  String get hadithSubtitle => 'Lire les recueils authentiques';

  @override
  String get hadithOfTheDay => 'HADITH DU JOUR';

  @override
  String get readMore => 'Lire la suite';

  @override
  String get qibla => 'Qibla';

  @override
  String get locationPermissionNeeded =>
      'L\'autorisation de localisation est requise.\nAccordez l\'accès pour calculer la direction de la Qibla.';

  @override
  String get grantPermission => 'Autoriser';

  @override
  String get noMagnetometer =>
      'Aucun capteur magnétomètre trouvé sur cet appareil.';

  @override
  String get kaabaMecca => 'Kaaba • La Mecque';

  @override
  String get kaabaDirection => 'DIRECTION DE LA KAABA';

  @override
  String get facingQibla => 'Vous êtes face à la Qibla';

  @override
  String get rotatePhone => 'Tournez votre téléphone';

  @override
  String get quran => 'Coran';

  @override
  String get quranSearchHint => 'Rechercher ou taper 2:255';

  @override
  String get surahs => 'Sourates';

  @override
  String get verses => 'Versets';

  @override
  String get juz => 'Juz';

  @override
  String get continueReading => 'Reprendre la lecture';

  @override
  String get connectionError => 'Erreur de connexion.';

  @override
  String get connectionErrorCheckInternet =>
      'Erreur de connexion.\nVeuillez vérifier votre connexion internet.';

  @override
  String get connectionErrorRetry => 'Erreur de connexion. Veuillez réessayer.';

  @override
  String get noVerseResults => 'Aucun verset trouvé.';

  @override
  String get goDirectly => 'Aller directement';

  @override
  String get copyArabic => 'Copier le texte arabe';

  @override
  String get copyTranslation => 'Copier la traduction';

  @override
  String get copied => 'Copié !';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get favorites => 'Favoris';

  @override
  String get noFavoritesYet => 'Vous n\'avez pas encore ajouté de favoris.';

  @override
  String get favoritesHint =>
      'Appuyez longuement sur un verset pour l\'ajouter aux favoris.';

  @override
  String get reciter => 'Récitateur';

  @override
  String get hadithSearchHint => 'Rechercher (texte ou n°)...';

  @override
  String get chapters => 'Chapitres';

  @override
  String get hadithsLabel => 'hadiths';

  @override
  String get collectionUnavailableInLang =>
      'Ce recueil n\'est pas disponible dans la langue choisie — affiché en anglais';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get noFavoriteHadith => 'Aucun hadith favori';

  @override
  String get favoriteHadithHint =>
      'Appuyez sur ⭐ pour ajouter un hadith à vos favoris';

  @override
  String get errorTimeout => 'La requête a expiré. Veuillez réessayer.';

  @override
  String get errorNoInternet =>
      'Pas de connexion internet. Vous êtes hors ligne.';

  @override
  String errorServer(int code) {
    return 'Erreur serveur ($code).';
  }

  @override
  String get fontSize => 'Taille du texte';

  @override
  String resumeReadingAt(int number) {
    return 'Reprenez où vous vous êtes arrêté · #$number';
  }

  @override
  String get favorite => 'Favori';

  @override
  String get favorited => 'Ajouté';

  @override
  String get copy => 'Copier';

  @override
  String get share => 'Partager';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get dataSource => 'Source des données';

  @override
  String get developer => 'Développeur';

  @override
  String get contact => 'Contact';

  @override
  String notifReminderTitle(String prayer) {
    return '🕌 Prière $prayer';
  }

  @override
  String notifReminderBody(String prayer, int minutes) {
    return '$minutes minutes avant la prière $prayer';
  }

  @override
  String notifAtTimeTitle(String prayer) {
    return '🕌 C\'est l\'heure de $prayer';
  }

  @override
  String notifAtTimeBody(String prayer) {
    return 'C\'est l\'heure de la prière $prayer';
  }
}
