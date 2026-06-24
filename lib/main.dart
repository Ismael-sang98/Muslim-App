import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/hive/hive_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_provider.dart';
import 'features/home/home_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/settings/settings_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Timezone — synchronous, before NotificationService.init()
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  // 2. Hive — register adapters and open boxes
  await HiveService.init();

  // 3. Notifications plugin
  await NotificationService.init();

  runApp(const ProviderScope(child: NamazVaktiApp()));
}

class NamazVaktiApp extends ConsumerWidget {
  const NamazVaktiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final onboardingDone = ref.watch(onboardingCompleteProvider);

    return MaterialApp(
      title: 'Namaz Vakti',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: onboardingDone ? const MainShell() : const OnboardingScreen(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [HomeScreen(), CalendarScreen(), SettingsScreen()];

  static const _icons = [
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: IndexedStack(
          key: ValueKey(_currentIndex),
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _CustomBottomNav(
        currentIndex: _currentIndex,
        icons: _icons,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<IconData> icons;
  final void Function(int) onTap;

  const _CustomBottomNav({
    required this.currentIndex,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF161B22)
            : AppTheme.darkGreen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, -3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(icons.length, (i) {
            final isActive = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 72,
                height: 61,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      icons[i],
                      size: 28,
                      color: isActive
                          ? AppTheme.accentOrange
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
