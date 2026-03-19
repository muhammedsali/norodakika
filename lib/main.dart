import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/welcome/screens/splash_screen.dart';
import 'features/settings/providers/language_provider.dart';
import 'features/settings/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

// Google Sign-In 7.x için Android'de serverClientId gerekiyor.
const String googleServerClientId =
    String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Bildirim servisini başlat
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: NorodakikaApp(),
    ),
  );
}

class NorodakikaApp extends ConsumerWidget {
  const NorodakikaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    ref.watch(languageProvider);
    
    return MaterialApp(
      title: 'NöroDakika',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6E00FF),
          primary: const Color(0xFF6E00FF),
          secondary: const Color(0xFF00E0FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6E00FF),
          primary: const Color(0xFF6E00FF),
          secondary: const Color(0xFF00E0FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1220),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

