import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Initialize auth provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.initialize();
      
      if (isLoggedIn) {
        _user = _authService.currentUser;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Failed to initialize: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      print('AuthProvider: Starting login...'); // Debug log
      final AuthResponse response = await _authService.login(
        email: email,
        password: password,
      );

      print('AuthProvider: Response received - isAuthSuccess: ${response.isAuthSuccess}'); // Debug log
      print('AuthProvider: Current user from service: ${_authService.currentUser}'); // Debug log
      print('AuthProvider: Token: ${response.token != null}'); // Debug log

      if (response.isAuthSuccess) {
        // Get user from auth service (already fetched during login)
        _user = _authService.currentUser;
        _status = AuthStatus.authenticated;
        print('AuthProvider: User authenticated successfully - ${_user?.email}'); // Debug log
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        _status = AuthStatus.unauthenticated;
        print('AuthProvider: Login failed - ${_errorMessage}'); // Debug log
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Login exception - $e'); // Debug log
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      final updatedUser = await _authService.getCurrentUser();
      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to refresh user: $e';
      notifyListeners();
    }
  }

  /// Check if user has specific role
  bool hasRole(String roleTitle) {
    return _authService.hasRole(roleTitle);
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roleTitles) {
    return _authService.hasAnyRole(roleTitles);
  }

  /// Check if user has specific permission
  bool hasPermission(String permissionTitle) {
    return _authService.hasPermission(permissionTitle);
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissionTitles) {
    return _authService.hasAnyPermission(permissionTitles);
  }

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissionTitles) {
    return _authService.hasAllPermissions(permissionTitles);
  }

  /// Check if user is approved
  bool get isApproved => _authService.isApproved;

  /// Check if email is verified
  bool get isEmailVerified => _authService.isEmailVerified;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
