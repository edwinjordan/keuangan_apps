import 'package:flutter/material.dart';
import 'package:keuangan_apps/services/rbac_service.dart';
import 'package:keuangan_apps/services/auth_service.dart';
import 'package:keuangan_apps/models/role.dart';

/// Example demonstrating how to use the RBAC endpoint
/// http://127.0.0.1:8000/api/v1/roles/1
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final rbacService = RbacService();
  final authService = AuthService();
  
  print('=== RBAC Example ===\n');
  
  // Example 1: Fetch Role by ID
  print('1. Fetching Admin role (ID: 1)...');
  final adminRole = await rbacService.getRoleById(1);
  
  if (adminRole != null) {
    print('✓ Role loaded: ${adminRole.title}');
    print('  ID: ${adminRole.id}');
    print('  Permissions: ${adminRole.permissions?.length ?? 0}');
    
    // List all permissions
    if (adminRole.permissions != null) {
      print('  Permission list:');
      for (var permission in adminRole.permissions!) {
        print('    - ${permission.title} (ID: ${permission.id})');
      }
    }
    
    // Check specific permissions
    print('\n  Permission checks:');
    print('    Has "cards_edit": ${adminRole.hasPermission("cards_edit")}');
    print('    Has "cards_view": ${adminRole.hasPermission("cards_view")}');
    print('    Has "cards_delete": ${adminRole.hasPermission("cards_delete")}');
  } else {
    print('✗ Failed to load role');
  }
  
  // Example 2: Fetch All Roles
  print('\n2. Fetching all roles...');
  final allRoles = await rbacService.getAllRoles();
  print('✓ Loaded ${allRoles.length} roles');
  for (var role in allRoles) {
    print('  - ${role.title} (${role.permissions?.length ?? 0} permissions)');
  }
  
  // Example 3: Check Current User Permissions
  print('\n3. Checking current user permissions...');
  if (authService.isLoggedIn) {
    final user = authService.currentUser;
    print('✓ User: ${user?.name}');
    print('  Email: ${user?.email}');
    print('  Roles: ${user?.getRoleTitles().join(", ")}');
    print('  Permissions: ${user?.getAllPermissions().join(", ")}');
    
    // Check specific permissions
    print('\n  Permission checks:');
    print('    Has "cards_edit": ${authService.hasPermission("cards_edit")}');
    print('    Has "cards_view": ${authService.hasPermission("cards_view")}');
    print('    Has "home_view": ${authService.hasPermission("home_view")}');
  } else {
    print('✗ No user logged in');
  }
  
  // Example 4: Refresh User Permissions
  print('\n4. Refreshing user role permissions...');
  final refreshed = await authService.refreshUserRolePermissions();
  if (refreshed) {
    print('✓ User permissions refreshed successfully');
  } else {
    print('✗ Failed to refresh permissions (user might not be logged in)');
  }
  
  print('\n=== Example Complete ===');
}

// Widget example showing permission-based UI
class PermissionBasedButton extends StatelessWidget {
  final String requiredPermission;
  final VoidCallback onPressed;
  final String label;
  
  const PermissionBasedButton({
    Key? key,
    required this.requiredPermission,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    // Only show button if user has permission
    if (!authService.hasPermission(requiredPermission)) {
      return const SizedBox.shrink();
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// Example: Protected Screen
class ProtectedScreen extends StatelessWidget {
  final String requiredPermission;
  final Widget child;
  
  const ProtectedScreen({
    Key? key,
    required this.requiredPermission,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    if (!authService.hasPermission(requiredPermission)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'You don\'t have permission to access this page',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Required permission: $requiredPermission',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    return child;
  }
}

// Example: Role-based menu items
List<MenuItem> getMenuItemsForUser(AuthService authService) {
  final menuItems = <MenuItem>[];
  
  // Home (visible to all authenticated users)
  if (authService.isLoggedIn) {
    menuItems.add(MenuItem(
      title: 'Home',
      icon: Icons.home,
      permission: 'home_view',
    ));
  }
  
  // Cards section (requires cards_view permission)
  if (authService.hasPermission('cards_view')) {
    menuItems.add(MenuItem(
      title: 'Cards',
      icon: Icons.credit_card,
      permission: 'cards_view',
    ));
  }
  
  // Transactions (requires transaction_view permission)
  if (authService.hasPermission('transaction_view')) {
    menuItems.add(MenuItem(
      title: 'Transactions',
      icon: Icons.receipt_long,
      permission: 'transaction_view',
    ));
  }
  
  // Reports (requires report_view permission)
  if (authService.hasPermission('report_view')) {
    menuItems.add(MenuItem(
      title: 'Reports',
      icon: Icons.analytics,
      permission: 'report_view',
    ));
  }
  
  // Settings (requires settings_view permission)
  if (authService.hasPermission('settings_view')) {
    menuItems.add(MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      permission: 'settings_view',
    ));
  }
  
  // Admin Panel (requires admin_access permission)
  if (authService.hasPermission('admin_access')) {
    menuItems.add(MenuItem(
      title: 'Admin Panel',
      icon: Icons.admin_panel_settings,
      permission: 'admin_access',
    ));
  }
  
  return menuItems;
}

class MenuItem {
  final String title;
  final IconData icon;
  final String permission;
  
  MenuItem({
    required this.title,
    required this.icon,
    required this.permission,
  });
}
