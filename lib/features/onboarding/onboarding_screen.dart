import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blob_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/location_detect_button.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BlobBackground()),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _SplashPage(onNext: _nextStep),
              _CityPage(onNext: _startOnboarding),
              const _LoadingPage(),
            ],
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    ref.read(onboardingProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _startOnboarding() async {
    ref.read(onboardingProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    await ref.read(onboardingProvider.notifier).completeOnboarding();
  }
}

// ─── Page 0: Splash ───────────────────────────────────────────────────────────

class _SplashPage extends StatelessWidget {
  final VoidCallback onNext;
  const _SplashPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset('assets/lg.png', fit: BoxFit.fitWidth),
            ),
          ),
          Column(
            children: [
              const Spacer(),
              Image.asset(
                'assets/Logo.png',
                height: 280,
                fit: BoxFit.contain,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.15),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _OnboardingButton(
                  label: AppLocalizations.of(context).startApp.toUpperCase(),
                  onPressed: onNext,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ),
              const Spacer(),
            ],
          ),
          // Mosque silhouette at bottom (IgnorePointer so button stays tappable)
        ],
      ),
    );
  }
}

// ─── Page 1: City ─────────────────────────────────────────────────────────────

class _CityPage extends ConsumerWidget {
  final Future<void> Function() onNext;
  const _CityPage({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Mosque silhouette at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset('assets/lg.png', fit: BoxFit.fitWidth),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Center(
                  child: Image.asset(
                    'assets/Logo.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ).animate().fadeIn(duration: 400.ms),
                ),
                const Spacer(),
                // Auto-detect city from GPS
                Center(
                  child: LocationDetectButton(
                    onDetected: (m) {
                      final notifier = ref.read(onboardingProvider.notifier);
                      notifier.selectProvince(m.provinceId, m.provinceNom);
                      if (m.hasDistrict) {
                        notifier.selectDistrict(m.districtId!, m.districtNom!);
                      } else {
                        _openDistrictPicker(
                          context,
                          ref,
                          ref.read(onboardingProvider),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Province
                Text(
                  l10n.province,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _GreenInputTile(
                  icon: Icons.public,
                  placeholder: l10n.selectProvince,
                  value: state.selectedProvinceName,
                  onTap: () => _openProvincePicker(context, ref),
                ),
                const SizedBox(height: 20),
                // District
                Text(
                  l10n.district,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _GreenInputTile(
                  icon: Icons.location_on_outlined,
                  placeholder: l10n.selectDistrict,
                  value: state.selectedDistrictName,
                  onTap: state.selectedProvinceId != null
                      ? () => _openDistrictPicker(context, ref, state)
                      : null,
                ),
                const Spacer(),
                _OnboardingButton(
                  label: l10n.continueButton,
                  onPressed: state.canComplete ? onNext : null,
                ).animate().fadeIn(delay: 300.ms),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openProvincePicker(BuildContext context, WidgetRef ref) {
    final villesTourquie = ref.read(villesTourquieProvider);
    villesTourquie.whenData((villes) {
      _showPickerSheet(
        context,
        title: AppLocalizations.of(context).selectProvince,
        items: villes.provinces.map((p) => (p.id, p.nom)).toList(),
        onSelect: (id, nom) {
          ref.read(onboardingProvider.notifier).selectProvince(id, nom);
          Navigator.pop(context);
        },
      );
    });
  }

  void _openDistrictPicker(
    BuildContext context,
    WidgetRef ref,
    OnboardingState state,
  ) {
    final villesTourquie = ref.read(villesTourquieProvider);
    villesTourquie.whenData((villes) {
      final province = villes.provinces
          .where((p) => p.id == state.selectedProvinceId)
          .firstOrNull;
      if (province == null) return;
      _showPickerSheet(
        context,
        title:
            '${AppLocalizations.of(context).selectDistrict} — ${province.nom}',
        items: province.districts.map((d) => (d.id, d.nom)).toList(),
        onSelect: (id, nom) {
          ref.read(onboardingProvider.notifier).selectDistrict(id, nom);
          Navigator.pop(context);
        },
      );
    });
  }

  void _showPickerSheet(
    BuildContext context, {
    required String title,
    required List<(String, String)> items,
    required void Function(String id, String nom) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _PickerSheet(title: title, items: items, onSelect: onSelect),
    );
  }
}

// ─── Page 2: Loading ──────────────────────────────────────────────────────────

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                AppLocalizations.of(context).welcome,
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 28),
              const SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(begin: const Offset(0.5, 0.5)),
              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset('assets/lg.png', fit: BoxFit.fitWidth),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Green input tile ─────────────────────────────────────────────────────────

class _GreenInputTile extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final String? value;
  final VoidCallback? onTap;

  const _GreenInputTile({
    required this.icon,
    required this.placeholder,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: GlassCard(
          radius: 14,
          blur: 14,
          fillOpacity: isEnabled ? 0.16 : 0.10,
          borderColor: hasValue
              ? AppTheme.lightGreen.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: isEnabled ? 0.22 : 0.12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: isEnabled ? 0.8 : 0.4),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue ? value! : placeholder,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: hasValue ? FontWeight.w400 : FontWeight.w300,
                    color: hasValue
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: isEnabled ? 0.7 : 0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Picker sheet ─────────────────────────────────────────────────────────────

class _PickerSheet extends StatefulWidget {
  final String title;
  final List<(String, String)> items;
  final void Function(String id, String nom) onSelect;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.onSelect,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) => item.$2.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchHint,
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white70),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  return ListTile(
                    title: Text(
                      item.$2,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                    ),
                    onTap: () => widget.onSelect(item.$1, item.$2),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Shared button ────────────────────────────────────────────────────────────

class _OnboardingButton extends StatelessWidget {
  final String label;
  final dynamic onPressed;

  const _OnboardingButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isEnabled ? () => onPressed() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.white : Colors.white38,
          foregroundColor: AppTheme.darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isEnabled ? AppTheme.darkGreen : Colors.white54,
          ),
        ),
      ),
    );
  }
}
