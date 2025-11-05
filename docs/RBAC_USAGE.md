# RBAC Implementation with API Endpoint

This document explains how to use the RBAC (Role-Based Access Control) system with the API endpoint `http://127.0.0.1:8000/api/v1/roles/{id}`.

## Overview

The RBAC system has been integrated with the following components:

1. **RbacService** - Dedicated service for role and permission management
2. **AuthService** - Extended with role-based permission checking
3. **Models** - Role and Permission models with JSON serialization

## API Endpoint

### Get Role by ID
```
GET http://127.0.0.1:8000/api/v1/roles/1
```

**Response Format:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "title": "Admin",
        "created_at": null,
        "updated_at": null,
        "deleted_at": null,
        "permissions": [
            {
                "id": 1,
                "title": "home_view",
                "created_at": null,
                "updated_at": null,
                "deleted_at": null,
                "pivot": {
                    "role_id": 1,
                    "permission_id": 1
                }
            },
            {
                "id": 2,
                "title": "cards_view",
                "created_at": null,
                "updated_at": null,
                "deleted_at": null,
                "pivot": {
                    "role_id": 1,
                    "permission_id": 2
                }
            }
        ]
    },
    "message": "Role retrieved successfully."
}
```

## Usage Examples

### 1. Fetch Role by ID

```dart
import 'package:keuangan_apps/services/rbac_service.dart';

final rbacService = RbacService();

// Fetch role with ID 1 (Admin)
final role = await rbacService.getRoleById(1);

if (role != null) {
  print('Role: ${role.title}');
  print('Permissions: ${role.getPermissionTitles()}');
  
  // Check if role has specific permission
  if (role.hasPermission('cards_edit')) {
    print('Role has cards_edit permission');
  }
}
```

### 2. Fetch All Roles

```dart
final roles = await rbacService.getAllRoles();

for (var role in roles) {
  print('${role.title}: ${role.permissions?.length ?? 0} permissions');
}
```

### 3. Check User Permissions

```dart
import 'package:keuangan_apps/services/auth_service.dart';

final authService = AuthService();

// Check if current user has specific permission
if (authService.hasPermission('cards_edit')) {
  // User can edit cards
  print('User can edit cards');
}

// Check if user has any of the specified permissions
if (authService.hasAnyPermission(['cards_view', 'cards_edit'])) {
  // User can view or edit cards
  print('User can access cards');
}

// Check if user has all permissions
if (authService.hasAllPermissions(['cards_view', 'cards_edit', 'cards_delete'])) {
  // User has full card permissions
  print('User has full card permissions');
}
```

### 4. Refresh User Permissions

```dart
// Refresh user's role permissions from server
final success = await authService.refreshUserRolePermissions();

if (success) {
  print('User permissions refreshed successfully');
}
```

### 5. Widget-Level Permission Checking

```dart
import 'package:flutter/material.dart';
import 'package:keuangan_apps/services/auth_service.dart';

class ProtectedWidget extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Only show if user has permission
    if (!_authService.hasPermission('cards_edit')) {
      return SizedBox.shrink(); // Hide widget
    }

    return ElevatedButton(
      onPressed: () {
        // Edit action
      },
      child: Text('Edit Card'),
    );
  }
}
```

### 6. Route Protection

```dart
import 'package:flutter/material.dart';
import 'package:keuangan_apps/services/auth_service.dart';

class ProtectedRoute extends StatelessWidget {
  final String requiredPermission;
  final Widget child;

  const ProtectedRoute({
    required this.requiredPermission,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    if (!authService.hasPermission(requiredPermission)) {
      return Scaffold(
        appBar: AppBar(title: Text('Access Denied')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'You do not have permission to access this page',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}

// Usage in routes
MaterialPageRoute(
  builder: (context) => ProtectedRoute(
    requiredPermission: 'cards_edit',
    child: EditCardScreen(),
  ),
);
```

### 7. Using Permission Widget

```dart
import 'package:flutter/material.dart';
import 'package:keuangan_apps/widgets/permission_widget.dart';

// Show widget only if user has permission
PermissionWidget(
  permission: 'cards_create',
  child: FloatingActionButton(
    onPressed: () {
      // Create new card
    },
    child: Icon(Icons.add),
  ),
);

// Show alternative widget if no permission
PermissionWidget(
  permission: 'admin_panel',
  child: AdminPanelButton(),
  fallback: Text('Contact admin for access'),
);
```

## Available Methods in RbacService

| Method | Description |
|--------|-------------|
| `getRoleById(int roleId)` | Fetch a specific role with permissions |
| `getAllRoles()` | Fetch all available roles |
| `getAllPermissions()` | Fetch all available permissions |
| `getRolePermissions(int roleId)` | Get permissions for a specific role |
| `getRolePermissionTitles(int roleId)` | Get permission titles for a role |
| `roleHasPermission(Role, String)` | Check if role has specific permission |
| `roleHasAnyPermission(Role, List<String>)` | Check if role has any permission |
| `roleHasAllPermissions(Role, List<String>)` | Check if role has all permissions |

## Available Methods in AuthService

| Method | Description |
|--------|-------------|
| `hasRole(String roleTitle)` | Check if user has specific role |
| `hasAnyRole(List<String> roleTitles)` | Check if user has any role |
| `hasPermission(String permission)` | Check if user has specific permission |
| `hasAnyPermission(List<String> permissions)` | Check if user has any permission |
| `hasAllPermissions(List<String> permissions)` | Check if user has all permissions |
| `getRoleById(int roleId)` | Fetch role by ID |
| `getAllRoles()` | Fetch all roles |
| `refreshUserRolePermissions()` | Refresh user's role permissions |

## Common Permission Examples

Based on your API response, here are common permissions:

- `home_view` - View home screen
- `cards_view` - View cards
- `cards_edit` - Edit cards
- `cards_show` - Show card details
- `cards_create` - Create new cards
- `cards_delete` - Delete cards (if available)

## Testing the Implementation

To test the RBAC implementation:

1. **Run the example screen:**
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => RbacExampleScreen(),
     ),
   );
   ```

2. **Check console output:**
   - Enable debug logging in services
   - Check for API calls and responses

3. **Test permission checks:**
   ```dart
   final authService = AuthService();
   print('Has cards_edit: ${authService.hasPermission('cards_edit')}');
   print('Has cards_view: ${authService.hasPermission('cards_view')}');
   ```

## Notes

- The base URL is set to `http://127.0.0.1:8000/api/v1` in `constants.dart`
- All API calls require authentication (Bearer token)
- The pivot data in permissions is automatically handled by JSON serialization
- Role and Permission models support null timestamps (created_at, updated_at, deleted_at)

## Troubleshooting

### Issue: "No roles loaded"
- Check if the API is running on `http://127.0.0.1:8000`
- Verify authentication token is valid
- Check network connectivity

### Issue: "Permission check always returns false"
- Ensure user is logged in
- Verify user has roles assigned
- Check if role has the required permission
- Use `refreshUserRolePermissions()` to sync with server

### Issue: "API returns 401 Unauthorized"
- Token might be expired - try logging in again
- Check if `Authorization` header is being sent
- Verify token format: `Bearer <token>`

## Next Steps

1. Implement role assignment for users
2. Add permission management UI
3. Create permission-based navigation guards
4. Add audit logging for permission checks
5. Implement permission caching for better performance
