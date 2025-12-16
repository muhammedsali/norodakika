import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/screens/auth_gate_screen.dart';
// TODO: flutterfire configure komutunu çalıştırdıktan sonra bu satırı açın
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  // Not: firebase_options.dart oluşturulduğunda options parametresi eklenmeli:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: NorodakikaApp(),
    ),
  );
}

class NorodakikaApp extends StatelessWidget {
  const NorodakikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NöroDakika',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6E00FF),
          primary: const Color(0xFF6E00FF),
          secondary: const Color(0xFF00E0FF),
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const AuthGateScreen(),
    );
  }
}

