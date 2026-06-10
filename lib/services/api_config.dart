class ApiConfig {
  // Public backend URL (deployed on Vercel)
  static const String _publicUrl = 'https://skin-scan-one.vercel.app';

  static String get baseUrl {
    return '$_publicUrl/api';
  }
}
