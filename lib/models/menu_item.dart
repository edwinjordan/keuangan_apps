import 'package:flutter/material.dart';

class MenuItem {
  final IconData icon;
  final String label;
  final String route;
  final List<String> requiredPermissions;
  final List<String>? requiredRoles;
  final VoidCallback? onTap;

  MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    this.requiredPermissions = const [],
    this.requiredRoles,
    this.onTap,
  });

  /// Check if user has access to this menu item
  bool hasAccess({
    required bool Function(String) hasPermission,
    required bool Function(String) hasRole,
  }) {
    // Check roles if specified
    if (requiredRoles != null && requiredRoles!.isNotEmpty) {
      bool hasRequiredRole = false;
      for (final role in requiredRoles!) {
        if (hasRole(role)) {
          hasRequiredRole = true;
          break;
        }
      }
      if (!hasRequiredRole) return false;
    }

    // Check permissions
    if (requiredPermissions.isNotEmpty) {
      for (final permission in requiredPermissions) {
        if (!hasPermission(permission)) {
          return false;
        }
      }
    }

    return true;
  }
}
