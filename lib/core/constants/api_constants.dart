class ApiConstants {
  // Toggle to true for local development with Go backend on localhost:5050
  static const bool useLocalhost = true;
  static const String serverUrl = useLocalhost
      ? 'http://localhost:5050'
      : 'https://ff-backend-klec.onrender.com';
  
  /// Base API Endpoint URL
  static const String baseUrl = '$serverUrl/api';

  static String sanitizeImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    String url = rawUrl.trim();

    if (url.contains('localhost:5050') || url.contains('127.0.0.1:5050')) {
      url = url
          .replaceAll('http://localhost:5050', serverUrl)
          .replaceAll('http://127.0.0.1:5050', serverUrl);
    }
    return url;
  }
}
