import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  static String? _authToken;

  /// Set authentication token
  static void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get authentication headers
  static Map<String, String> _getHeaders({bool includeAuth = false}) {
    Map<String, String> headers = Map.from(ApiConstants.headers);
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Handle HTTP response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return json.decode(response.body);
      } catch (e) {
        throw ApiException('Failed to parse response: $e');
      }
    } else {
      String errorMessage = 'Request failed';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  /// GET request
  static Future<dynamic> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParameters,
  }) async {
    try {
      Uri uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await http
          .get(
            uri,
            headers: _getHeaders(includeAuth: requiresAuth),
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// POST request
  static Future<dynamic> post(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(includeAuth: requiresAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// PUT request
  static Future<dynamic> put(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(includeAuth: requiresAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// PATCH request
  static Future<dynamic> patch(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(includeAuth: requiresAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// DELETE request
  static Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(includeAuth: requiresAuth),
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}
