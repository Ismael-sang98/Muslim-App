import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notifications/notification_service.dart';
import '../settings/settings_provider.dart';

// ─── City data models ────────────────────────────────────────────────────────

class District {
  final String id;
  final String nom;
  const District({required this.id, required this.nom});

  factory District.fromJson(Map<String, dynamic> json) => District(
        id: json['id'] as String,
        nom: json['nom'] as String,
      );
}

class Province {
  final String id;
  final String nom;
  final List<District> districts;
  const Province(
      {required this.id, required this.nom, required this.districts});

  factory Province.fromJson(Map<String, dynamic> json) => Province(
        id: json['province_id'] as String,
        nom: json['province_nom'] as String,
        districts: (json['districts'] as List)
            .map((d) => District.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}

class VillesTourquie {
  final List<Province> provinces;
  const VillesTourquie({required this.provinces});

  factory VillesTourquie.fromJson(List<dynamic> json) => VillesTourquie(
        provinces: json
            .map((p) => Province.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}

final villesTourquieProvider = FutureProvider<VillesTourquie>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/villes_turquie.json');
  return VillesTourquie.fromJson(jsonDecode(jsonStr) as List<dynamic>);
});

// ─── Onboarding state ─────────────────────────────────────────────────────────

class OnboardingState {
  final int step;
  final String selectedLanguage;
  final String? selectedProvinceId;
  final String? selectedProvinceName;
  final String? selectedDistrictId;
  final String? selectedDistrictName;
  final bool notifPermissionGranted;

  const OnboardingState({
    this.step = 0,
    this.selectedLanguage = 'tr',
    this.selectedProvinceId,
    this.selectedProvinceName,
    this.selectedDistrictId,
    this.selectedDistrictName,
    this.notifPermissionGranted = false,
  });

  bool get canProceedToCity => step >= 1;
  bool get canComplete =>
      selectedDistrictId != null && selectedDistrictId!.isNotEmpty;

  OnboardingState copyWith({
    int? step,
    String? selectedLanguage,
    String? selectedProvinceId,
    String? selectedProvinceName,
    String? selectedDistrictId,
    String? selectedDistrictName,
    bool? notifPermissionGranted,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedProvinceId: selectedProvinceId ?? this.selectedProvinceId,
      selectedProvinceName: selectedProvinceName ?? this.selectedProvinceName,
      selectedDistrictId: selectedDistrictId ?? this.selectedDistrictId,
      selectedDistrictName: selectedDistrictName ?? this.selectedDistrictName,
      notifPermissionGranted:
          notifPermissionGranted ?? this.notifPermissionGranted,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState());

  void selectLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  void selectProvince(String id, String name) {
    state = state.copyWith(
      selectedProvinceId: id,
      selectedProvinceName: name,
      selectedDistrictId: null,
      selectedDistrictName: null,
    );
  }

  void selectDistrict(String id, String name) {
    state = state.copyWith(
      selectedDistrictId: id,
      selectedDistrictName: name,
    );
  }

  void nextStep() {
    if (state.step < 2) state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  Future<void> completeOnboarding() async {
    if (!state.canComplete) return;

    // updateCity persists to Hive and triggers state = state → onboardingCompleteProvider flips
    await _ref.read(settingsProvider.notifier).updateCity(
          state.selectedDistrictId!,
          state.selectedDistrictName ?? '',
          provinceNom: state.selectedProvinceName ?? '',
        );

    final granted = await NotificationService.requestPermission();
    await NotificationService.requestBatteryOptimizationExemption();
    state = state.copyWith(notifPermissionGranted: granted);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(ref),
);

final onboardingCompleteProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.villeId.isNotEmpty;
});
