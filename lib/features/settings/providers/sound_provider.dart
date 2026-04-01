import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/audio_service.dart';

class SoundSettings {
  final bool isSoundEnabled;
  final bool isMusicEnabled;

  SoundSettings({required this.isSoundEnabled, required this.isMusicEnabled});

  SoundSettings copyWith({bool? isSoundEnabled, bool? isMusicEnabled}) {
    return SoundSettings(
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
    );
  }
}

final soundSettingsProvider = StateNotifierProvider<SoundSettingsNotifier, SoundSettings>((ref) {
  return SoundSettingsNotifier();
});

class SoundSettingsNotifier extends StateNotifier<SoundSettings> {
  SoundSettingsNotifier() : super(SoundSettings(isSoundEnabled: true, isMusicEnabled: true)) {
    _load();
  }

  Future<void> _load() async {
    final sound = await LocalStorageService.getIsSoundEnabled();
    final music = await LocalStorageService.getIsMusicEnabled();
    state = SoundSettings(isSoundEnabled: sound, isMusicEnabled: music);
    
    // Apply initial settings to audio service
    final audioService = AudioService();
    audioService.setSoundEnabled(sound);
    audioService.setMusicEnabled(music);
  }

  Future<void> toggleSound() async {
    final newValue = !state.isSoundEnabled;
    state = state.copyWith(isSoundEnabled: newValue);
    await LocalStorageService.setIsSoundEnabled(newValue);
    
    final audioService = AudioService();
    audioService.setSoundEnabled(newValue);
  }

  Future<void> toggleMusic() async {
    final newValue = !state.isMusicEnabled;
    state = state.copyWith(isMusicEnabled: newValue);
    await LocalStorageService.setIsMusicEnabled(newValue);
    
    final audioService = AudioService();
    audioService.setMusicEnabled(newValue);
  }
}
