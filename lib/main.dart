import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make status bars completely transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // For light mode initially
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const WalloraApp());
}

class WalloraApp extends StatelessWidget {
  const WalloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallora',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      // --- STRICT WHITE LIGHT THEME ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Pure White Background
        colorScheme: const ColorScheme.light(
          primary: Colors.black, // Primary actions are black
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          background: Colors.white,
          onBackground: Colors.black, // Text is black
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      // --- STRICT BLACK DARK THEME ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Pure Black Background
        colorScheme: const ColorScheme.dark(
          primary: Colors.white, // Primary actions are white
          onPrimary: Colors.black,
          secondary: Colors.white,
          onSecondary: Colors.black,
          background: Colors.black,
          onBackground: Colors.white, // Text is white
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}