import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_page.dart';
import 'screens/welcome_screen.dart';
import 'services/update_service.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ThemeService
  await ThemeService.instance.init();

  // Initialize Notifications and Background Worker
  await NotificationService.instance.init();
  await BackgroundService.instance.init();
  await AuthService.instance.checkAuthStatus();

  // 1. Force Edge-to-Edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. Set transparent overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(WalloraApp(isFirstTime: isFirstTime));
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
    // Silent check for updates on startup
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

          // --- LIGHT THEME (Pure White) ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1), // Indigo/Modern vibe
              primary: const Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1E293B),
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
          ),

          // --- DARK THEME (Sleek Deep Black/Blue) ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(
              0xFF0F172A,
            ), // Modern deep navy
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF818CF8),
              brightness: Brightness.dark,
              primary: const Color(0xFF818CF8),
              onPrimary: const Color(0xFF0F172A),
              surface: const Color(0xFF1E293B),
              onSurface: Colors.white,
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
          ),
          home: widget.isFirstTime ? const WelcomeScreen() : const HomePage(),
        );
      },
    );
  }
}
