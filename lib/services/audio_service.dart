/// Ses efektleri servisi
/// Müşteri isteği üzerine performansı artırmak ve çökmeleri engellemek için sesler tamamen devredışı bırakıldı.
class AudioService {
  const AudioService();

  Future<void> playSound(String soundName) async {}
  Future<void> playMusic(String musicName) async {}
  Future<void> stopMusic() async {}

  void setSoundEnabled(bool enabled) {}
  void setMusicEnabled(bool enabled) {}

  bool get isSoundEnabled => false;
  bool get isMusicEnabled => false;

  Future<void> playCorrect() async {}
  Future<void> playWrong() async {}
  Future<void> playTap() async {}
  Future<void> playSuccess() async {}
  Future<void> playGameOver() async {}
  Future<void> playCountdown() async {}
  Future<void> playLevelUp() async {}

  void dispose() {}
}
