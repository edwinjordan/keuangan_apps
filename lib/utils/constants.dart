class ApiConstants {
  // Base URL - Ganti dengan URL backend Anda
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String meEndpoint = '/auth/me';
  static const String refreshEndpoint = '/auth/refresh';
  
  // User endpoints
  static const String usersEndpoint = '/users';
  
  // Role endpoints
  static const String rolesEndpoint = '/roles';
  
  // Permission endpoints
  static const String permissionsEndpoint = '/permissions';
  
  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
