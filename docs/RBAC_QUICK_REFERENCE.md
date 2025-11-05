# RBAC Quick Reference

## API Endpoint
```
GET http://127.0.0.1:8000/api/v1/roles/1
```

## Quick Start

### 1. Import Services
```dart
import 'package:keuangan_apps/services/rbac_service.dart';
import 'package:keuangan_apps/services/auth_service.dart';
```

### 2. Initialize
```dart
final rbacService = RbacService();
final authService = AuthService();
```

## Common Operations

### Fetch Role by ID
```dart
final role = await rbacService.getRoleById(1);
```

### Check Permission
```dart
if (authService.hasPermission('cards_edit')) {
  // Allow action
}
```

### Check Multiple Permissions
```dart
// Any permission
if (authService.hasAnyPermission(['cards_view', 'cards_edit'])) {
  // Has at least one
}

// All permissions
if (authService.hasAllPermissions(['cards_view', 'cards_edit'])) {
  // Has all
}
```

### Refresh Permissions
```dart
await authService.refreshUserRolePermissions();
```

## UI Components

### Permission Widget
```dart
PermissionWidget(
  permission: 'cards_create',
  child: MyButton(),
)
```

### Protected Screen
```dart
if (!authService.hasPermission('admin_access')) {
  return AccessDeniedScreen();
}
return AdminScreen();
```

### Conditional Button
```dart
if (authService.hasPermission('cards_edit'))
  ElevatedButton(
    onPressed: () => editCard(),
    child: Text('Edit'),
  )
```

## Available Permissions
- `home_view`
- `cards_view`
- `cards_edit`
- `cards_show`
- `cards_create`

## Key Methods

| Service | Method | Purpose |
|---------|--------|---------|
| RbacService | `getRoleById(id)` | Fetch role with permissions |
| RbacService | `getAllRoles()` | Get all roles |
| AuthService | `hasPermission(name)` | Check user permission |
| AuthService | `hasAnyPermission(list)` | Check any permission |
| AuthService | `hasAllPermissions(list)` | Check all permissions |
| AuthService | `refreshUserRolePermissions()` | Sync with server |

## Example Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RbacExampleScreen(),
  ),
);
```

## Documentation
- Full guide: `docs/RBAC_USAGE.md`
- Examples: `lib/examples/rbac_usage_example.dart`
- Summary: `docs/RBAC_INTEGRATION_SUMMARY.md`
