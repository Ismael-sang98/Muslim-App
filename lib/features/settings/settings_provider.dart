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

