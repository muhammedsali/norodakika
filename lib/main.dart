import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/screens/home_screen.dart';

void main() {
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
      home: const HomeScreen(),
    );
  }
}

