import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/hive/hive_service.dart';
import '../../core/hive/models/settings_model.dart';

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(HiveService.getOrCreateSettings());

  // HiveObject is mutable — same reference after mutation, so force notify always
  @override
  bool updateShouldNotify(SettingsModel old, SettingsModel current) => true;

  Future<void> updateCity(String villeId, String villeNom,
      {String? provinceNom}) async {
    state.villeId = villeId;
    state.villeNom = villeNom;
    if (provinceNom != null) state.villeProvinceNom = provinceNom;
    await state.save();
    state = state;
  }

  Future<void> updateTheme(String themeMode) async {
    state.themeMode = themeMode;
    await state.save();
    state = state;
  }

  Future<void> toggleNotification(String prayerKey, bool value) async {
    state.setNotification(prayerKey, value);
    await state.save();
    state = state;
  }

  Future<void> updateReminderMinutes(int minutes) async {
    state.minutesAvantRappel = minutes;
    await state.save();
    state = state;
  }

  Future<void> updateHadithLanguage(String lang) async {
    state.hadithLangue = lang;
    await state.save();
    state = state;
  }

  /// App-wide language (drives UI + hadith content, kept in sync).
  Future<void> updateLanguage(String lang) async {
    state.langue = lang;
    state.hadithLangue = lang;
    await state.save();
    state = state;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(),
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return switch (settings.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});

/// App locale derived from the persisted language setting.
final appLocaleProvider = Provider<Locale>((ref) {
  final lang = ref.watch(settingsProvider).langue;
  return switch (lang) {
    'en' => const Locale('en'),
    'fr' => const Locale('fr'),
    _ => const Locale('tr'),
  };
});

