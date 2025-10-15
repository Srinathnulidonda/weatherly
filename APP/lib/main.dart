import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart'; // Add this import
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'utils/theme_manager.dart';
import 'utils/notification_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await NotificationManager.initialize();
  await ThemeManager.initialize();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.dark(
          primary: ThemeManager.primaryColor,
          secondary: ThemeManager.primaryColor,
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      routes: {
        '/': (context) => const SplashScreen(), // Changed from HomeScreen
        '/home': (context) => const HomeScreen(), // Added home route
        '/settings': (context) => const SettingsScreen(),
        '/about': (context) => const AboutScreen(),
      },
      initialRoute: '/',
    );
  }
}