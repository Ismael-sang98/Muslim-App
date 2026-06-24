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
}
