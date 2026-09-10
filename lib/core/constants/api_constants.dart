class ApiConstants {
  // Connected to production Go backend on Render
  static const bool useLocalhost = false;
  static const String serverUrl = useLocalhost
      ? 'http://localhost:5050'
      : 'https://ff-backend-klec.onrender.com';
  
  /// Base API Endpoint URL
  static const String baseUrl = '$serverUrl/api';

  static String sanitizeImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    String url = rawUrl.trim();

    if (useLocalhost) {
      if (url.contains('onrender.com')) {
        url = url.replaceAll(
          RegExp(r'https?://[a-zA-Z0-9\.-]*onrender\.com'),
          serverUrl,
        );
      }
    } else {
      if (url.contains('localhost:') || url.contains('127.0.0.1:')) {
        url = url.replaceAll(
          RegExp(r'http://(localhost|127\.0\.0\.1):(5050|8080|5000)'),
          serverUrl,
        );
      }
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('/')) {
        url = '$serverUrl$url';
      } else {
        url = '$serverUrl/uploads/$url';
      }
    }

    return url;
  }
}
