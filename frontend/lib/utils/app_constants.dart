class AppConstants {
  // ── Change this URL based on where you run the app ──
  // Chrome / Web:        'http://localhost:3000'
  // Android emulator:   'http://10.0.2.2:3000'
  // Real phone (WiFi):  'http://YOUR-PC-IP:3000'
  static const String baseUrl = 'http://localhost:3000';

  static const String tokenKey = 'auth_token';
  static const List<String> priorities = ['low', 'medium', 'high'];
  static const List<String> categories = [
    'assignment', 'exam', 'lab', 'project', 'other'
  ];
}
