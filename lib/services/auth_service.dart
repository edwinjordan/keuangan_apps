import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../models/permission.dart';
import '../models/auth_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  User? _currentUser;
  String? _authToken;

  /// Get current authenticated user
  User? get currentUser => _currentUser;

  /// Get current auth token
  String? get authToken => _authToken;

  /// Check if user is logged in
  bool get isLoggedIn => _authToken != null && _currentUser != null;

  /// Initialize auth service - load saved credentials
  Future<bool> initialize() async {
    try {
      // Load token from secure storage
      _authToken = await _secureStorage.read(key: ApiConstants.tokenKey);
      
      if (_authToken != null) {
        // Set token in API service
        ApiService.setAuthToken(_authToken);
        
        // Load user data from preferences
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString(ApiConstants.userKey);
        
        if (userJson != null) {
          _currentUser = User.fromJson(json.decode(userJson));
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error initializing auth service: $e');
      return false;
    }
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthService: Sending login request...'); // Debug log
      final response = await ApiService.post(
        ApiConstants.loginEndpoint,
        body: {
          'email': email,
          'password': password,
        },
      );

      print('AuthService: Response received: $response'); // Debug log

      final authResponse = AuthResponse.fromJson(response);
      print('AuthService: AuthResponse parsed - isSuccess: ${authResponse.isAuthSuccess}'); // Debug log
      print('AuthService: Token: ${authResponse.token != null}'); // Debug log

      if (authResponse.isAuthSuccess) {
        // Save token first
        _authToken = authResponse.token;
        ApiService.setAuthToken(_authToken);
        await _secureStorage.write(key: ApiConstants.tokenKey, value: _authToken);
        
        print('AuthService: Token saved, fetching user data...'); // Debug log
        
        try {
          // Try to fetch current user data
          final user = await getCurrentUser();
          
          if (user != null) {
            _currentUser = user;
            print('AuthService: User data fetched successfully'); // Debug log
          } else {
            print('AuthService: getCurrentUser returned null, creating dummy user'); // Debug log
            // Create dummy user if endpoint not available
            _currentUser = _createDummyUser(email);
            await _saveUserData(_currentUser!);
            print('AuthService: Dummy user created and saved: ${_currentUser!.name}'); // Debug log
          }
        } catch (e) {
          print('AuthService: Exception fetching user data: $e'); // Debug log
          print('AuthService: Creating dummy user as fallback'); // Debug log
          // Create dummy user if endpoint fails
          _currentUser = _createDummyUser(email);
          await _saveUserData(_currentUser!);
          print('AuthService: Dummy user created from exception: ${_currentUser!.name}'); // Debug log
        }
      }

      return authResponse;
    } catch (e) {
      print('AuthService: Login error - $e'); // Debug log
      rethrow;
    }
  }

  /// Create dummy user for testing when /auth/me endpoint is not available
  User _createDummyUser(String email) {
    return User(
      id: 1,
      name: email.split('@')[0].replaceAll('.', ' ').split(' ')
          .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
          .join(' '),
      email: email,
      emailVerifiedAt: DateTime.now(),
      approved: true,
      roles: [
        Role(
          id: 1,
          title: 'User',
          permissions: [
            Permission(id: 1, title: 'dashboard_access'),
            Permission(id: 2, title: 'view_transactions'),
            Permission(id: 3, title: 'view_cards'),
            Permission(id: 4, title: 'view_statistics'),
            Permission(id: 5, title: 'create_transaction'),
          ],
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint if token exists
      if (_authToken != null) {
        try {
          await ApiService.post(
            ApiConstants.logoutEndpoint,
            requiresAuth: true,
          );
        } catch (e) {
          print('Error calling logout endpoint: $e');
          // Continue with local logout even if API call fails
        }
      }
    } finally {
      // Clear local data regardless of API call result
      await _clearAuthData();
    }
  }

  /// Get current user from server
  Future<User?> getCurrentUser() async {
    try {
      if (_authToken == null) return null;

      final response = await ApiService.get(
        ApiConstants.meEndpoint,
        requiresAuth: true,
      );

      if (response != null) {
        _currentUser = User.fromJson(response['user'] ?? response);
        await _saveUserData(_currentUser!);
        return _currentUser;
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Refresh auth token
  Future<bool> refreshToken() async {
    try {
      if (_authToken == null) return false;

      final response = await ApiService.post(
        ApiConstants.refreshEndpoint,
        requiresAuth: true,
      );

      if (response != null && response['token'] != null) {
        await _saveToken(response['token']);
        return true;
      }

      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  /// Save authentication data
  Future<void> _saveAuthData(String token, User user) async {
    _authToken = token;
    _currentUser = user;

    // Save token to secure storage
    await _secureStorage.write(key: ApiConstants.tokenKey, value: token);

    // Save user to shared preferences
    await _saveUserData(user);

    // Set token in API service
    ApiService.setAuthToken(token);
  }

  /// Save user data to shared preferences
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.userKey, json.encode(user.toJson()));
  }

  /// Save token
  Future<void> _saveToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: ApiConstants.tokenKey, value: token);
    ApiService.setAuthToken(token);
  }

  /// Clear authentication data
  Future<void> _clearAuthData() async {
    _authToken = null;
    _currentUser = null;

    // Clear secure storage
    await _secureStorage.delete(key: ApiConstants.tokenKey);
    await _secureStorage.delete(key: ApiConstants.refreshTokenKey);

    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.userKey);

    // Clear API service token
    ApiService.setAuthToken(null);
  }

  /// Check if user has specific role
  bool hasRole(String roleTitle) {
    return _currentUser?.hasRole(roleTitle) ?? false;
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roleTitles) {
    return _currentUser?.hasAnyRole(roleTitles) ?? false;
  }

  /// Check if user has specific permission
  bool hasPermission(String permissionTitle) {
    return _currentUser?.hasPermission(permissionTitle) ?? false;
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissionTitles) {
    return _currentUser?.hasAnyPermission(permissionTitles) ?? false;
  }

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissionTitles) {
    return _currentUser?.hasAllPermissions(permissionTitles) ?? false;
  }

  /// Check if user is approved
  bool get isApproved => _currentUser?.isApproved ?? false;

  /// Check if email is verified
  bool get isEmailVerified => _currentUser?.isEmailVerified ?? false;
}
