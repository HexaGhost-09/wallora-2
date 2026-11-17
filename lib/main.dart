import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'screens/home_page.dart';
import 'screens/welcome_screen.dart';
import 'services/update_service.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThemeService.instance.init();
  await NotificationService.instance.init();
  await BackgroundService.instance.init();
  await AuthService.instance.checkAuthStatus();

  final isMobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (isMobile) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;
  runApp(WalloraApp(isFirstTime: isFirstTime));
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const accent = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class WalloraApp extends StatefulWidget {
  final bool isFirstTime;
  const WalloraApp({super.key, required this.isFirstTime});

  @override
  State<WalloraApp> createState() => _WalloraAppState();
}

class _WalloraAppState extends State<WalloraApp> {
  @override
  void initState() {
    super.initState();
    UpdateService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Wallora',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService.instance.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              primary: const Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1E293B),
              surfaceContainerHighest: const Color(0xFFF1F5F9),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0F1E),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF818CF8),
              brightness: Brightness.dark,
              primary: const Color(0xFF818CF8),
              onPrimary: const Color(0xFF0F172A),
              surface: const Color(0xFF141B2D),
              onSurface: const Color(0xFFF1F5F9),
              surfaceContainerHighest: const Color(0xFF1E293B),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          home: widget.isFirstTime
              ? const WelcomeScreen()
              : const _WhatsNewGate(child: HomePage()),
        );
      },
    );
  }
}

class _WhatsNewGate extends StatefulWidget {
  final Widget child;
  const _WhatsNewGate({required this.child});

  @override
  State<_WhatsNewGate> createState() => _WhatsNewGateState();
}

class _WhatsNewGateState extends State<_WhatsNewGate> {
  static const _shownKey = 'whats_new_v1_7_2_shown';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOnce());
  }

  Future<void> _showOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_shownKey) ?? false) return;

    // Persist before opening so interruptions cannot make the dialog repeat.
    await prefs.setBool(_shownKey, true);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              const Expanded(child: Text("What's new in 1.7.2")),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                _ChangeItem(
                  title: 'Category search',
                  detail: 'Search categories separately and open matching wallpaper collections.',
                ),
                SizedBox(height: 16),
                _ChangeItem(
                  title: 'Smoother navigation',
                  detail: 'Refined the Settings icon animation and bottom navigation transitions.',
                ),
                SizedBox(height: 16),
                _ChangeItem(
                  title: 'Fixes',
                  detail: 'Fixed the sketchy Settings icon switch and improved search result handling.',
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ChangeItem extends StatelessWidget {
  final String title;
  final String detail;

  const _ChangeItem({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded,
            size: 19, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 3),
              Text(detail, style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.68),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
