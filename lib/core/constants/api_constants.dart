class ApiConstants {
  // Toggle to true for local development with Go backend on localhost:5050
  static const bool useLocalhost = true;
  static const String serverUrl = useLocalhost
      ? 'http://localhost:5050'
      : 'https://ff-backend-klec.onrender.com';
  
  /// Base API Endpoint URL
  static const String baseUrl = '$serverUrl/api';
}
