import '../models/role.dart';
import '../models/permission.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// RBAC (Role-Based Access Control) Service
/// Handles role and permission management
class RbacService {
  static final RbacService _instance = RbacService._internal();
  factory RbacService() => _instance;
  RbacService._internal();

  /// Fetch role details by ID with permissions
  /// Endpoint: GET /api/v1/roles/{id}
  /// Example: http://127.0.0.1:8000/api/v1/roles/1
  /// 
  /// Response format:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "id": 1,
  ///     "title": "Admin",
  ///     "permissions": [...]
  ///   },
  ///   "message": "Role retrieved successfully."
  /// }
  Future<Role?> getRoleById(int roleId) async {
    try {
      final response = await ApiService.get(
        '${ApiConstants.rolesEndpoint}/$roleId',
        requiresAuth: true,
      );

      if (response != null && response['success'] == true) {
        final roleData = response['data'];
        return Role.fromJson(roleData);
      }

      return null;
    } catch (e) {
      print('RbacService - Error fetching role by ID: $e');
      return null;
    }
  }

  /// Fetch all roles
  /// Endpoint: GET /api/v1/roles
  Future<List<Role>> getAllRoles() async {
    try {
      final response = await ApiService.get(
        ApiConstants.rolesEndpoint,
        requiresAuth: true,
      );

      if (response != null) {
        // Handle wrapped response
        if (response['success'] == true && response['data'] != null) {
          final rolesData = response['data'] as List;
          return rolesData.map((json) => Role.fromJson(json)).toList();
        }
        // Handle direct array response
        else if (response is List) {
          return response.map((json) => Role.fromJson(json)).toList();
        }
      }

      return [];
    } catch (e) {
      print('RbacService - Error fetching all roles: $e');
      return [];
    }
  }

  /// Fetch all permissions
  /// Endpoint: GET /api/v1/permissions
  Future<List<Permission>> getAllPermissions() async {
    try {
      final response = await ApiService.get(
        ApiConstants.permissionsEndpoint,
        requiresAuth: true,
      );

      if (response != null) {
        // Handle wrapped response
        if (response['success'] == true && response['data'] != null) {
          final permissionsData = response['data'] as List;
          return permissionsData.map((json) => Permission.fromJson(json)).toList();
        }
        // Handle direct array response
        else if (response is List) {
          return response.map((json) => Permission.fromJson(json)).toList();
        }
      }

      return [];
    } catch (e) {
      print('RbacService - Error fetching all permissions: $e');
      return [];
    }
  }

  /// Check if a role has specific permission
  bool roleHasPermission(Role role, String permissionTitle) {
    return role.hasPermission(permissionTitle);
  }

  /// Check if a role has any of the specified permissions
  bool roleHasAnyPermission(Role role, List<String> permissionTitles) {
    if (role.permissions == null) return false;
    return permissionTitles.any((title) => role.hasPermission(title));
  }

  /// Check if a role has all of the specified permissions
  bool roleHasAllPermissions(Role role, List<String> permissionTitles) {
    if (role.permissions == null) return false;
    return permissionTitles.every((title) => role.hasPermission(title));
  }

  /// Get permissions for a specific role by ID
  Future<List<Permission>> getRolePermissions(int roleId) async {
    try {
      final role = await getRoleById(roleId);
      return role?.permissions ?? [];
    } catch (e) {
      print('RbacService - Error fetching role permissions: $e');
      return [];
    }
  }

  /// Get permission titles for a specific role
  Future<List<String>> getRolePermissionTitles(int roleId) async {
    try {
      final permissions = await getRolePermissions(roleId);
      return permissions.map((p) => p.title).toList();
    } catch (e) {
      print('RbacService - Error fetching role permission titles: $e');
      return [];
    }
  }

  /// Create a role (if your API supports it)
  Future<Role?> createRole({
    required String title,
    List<int>? permissionIds,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.rolesEndpoint,
        requiresAuth: true,
        body: {
          'title': title,
          if (permissionIds != null) 'permission_ids': permissionIds,
        },
      );

      if (response != null && response['success'] == true) {
        final roleData = response['data'];
        return Role.fromJson(roleData);
      }

      return null;
    } catch (e) {
      print('RbacService - Error creating role: $e');
      return null;
    }
  }

  /// Update a role (if your API supports it)
  Future<Role?> updateRole({
    required int roleId,
    String? title,
    List<int>? permissionIds,
  }) async {
    try {
      final response = await ApiService.put(
        '${ApiConstants.rolesEndpoint}/$roleId',
        requiresAuth: true,
        body: {
          if (title != null) 'title': title,
          if (permissionIds != null) 'permission_ids': permissionIds,
        },
      );

      if (response != null && response['success'] == true) {
        final roleData = response['data'];
        return Role.fromJson(roleData);
      }

      return null;
    } catch (e) {
      print('RbacService - Error updating role: $e');
      return null;
    }
  }

  /// Delete a role (if your API supports it)
  Future<bool> deleteRole(int roleId) async {
    try {
      final response = await ApiService.delete(
        '${ApiConstants.rolesEndpoint}/$roleId',
        requiresAuth: true,
      );

      return response != null && response['success'] == true;
    } catch (e) {
      print('RbacService - Error deleting role: $e');
      return false;
    }
  }

  /// Assign permissions to a role (if your API supports it)
  Future<bool> assignPermissionsToRole({
    required int roleId,
    required List<int> permissionIds,
  }) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.rolesEndpoint}/$roleId/permissions',
        requiresAuth: true,
        body: {
          'permission_ids': permissionIds,
        },
      );

      return response != null && response['success'] == true;
    } catch (e) {
      print('RbacService - Error assigning permissions to role: $e');
      return false;
    }
  }

  /// Remove permissions from a role (if your API supports it)
  Future<bool> removePermissionsFromRole({
    required int roleId,
    required List<int> permissionIds,
  }) async {
    try {
      // Use POST or PUT for deleting with body, or adjust based on your API
      final response = await ApiService.post(
        '${ApiConstants.rolesEndpoint}/$roleId/permissions/remove',
        requiresAuth: true,
        body: {
          'permission_ids': permissionIds,
        },
      );

      return response != null && response['success'] == true;
    } catch (e) {
      print('RbacService - Error removing permissions from role: $e');
      return false;
    }
  }
}
