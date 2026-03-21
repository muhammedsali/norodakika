class AppConstants {
  // Renkler
  static const primaryColor = 0xFF6E00FF;
  static const accentColor = 0xFF00E0FF;

  // API
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.norodakika.com',
  );
}
