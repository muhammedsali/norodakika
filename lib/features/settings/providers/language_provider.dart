import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';

enum AppLanguage { tr, en }

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.tr) {
    _load();
  }

  Future<void> _load() async {
    final code = await LocalStorageService.getLanguageCode();
    if (code == 'en') {
      state = AppLanguage.en;
    } else {
      state = AppLanguage.tr;
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final code = lang == AppLanguage.en ? 'en' : 'tr';
    await LocalStorageService.setLanguageCode(code);
  }
}
