import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final isDark = await LocalStorageService.getIsDarkMode();
    state = isDark;
  }

  Future<void> toggleTheme() async {
    state = !state;
    await LocalStorageService.setIsDarkMode(state);
  }

  Future<void> setDarkMode(bool isDark) async {
    state = isDark;
    await LocalStorageService.setIsDarkMode(isDark);
  }
}
