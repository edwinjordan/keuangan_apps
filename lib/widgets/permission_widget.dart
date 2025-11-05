import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Widget that shows its child only if the user has the required permissions
class PermissionWidget extends StatelessWidget {
  final List<String> requiredPermissions;
  final Widget child;
  final Widget? fallback;
  final bool requireAll;

  const PermissionWidget({
    super.key,
    required this.requiredPermissions,
    required this.child,
    this.fallback,
    this.requireAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final hasPermission = requireAll
            ? authProvider.hasAllPermissions(requiredPermissions)
            : authProvider.hasAnyPermission(requiredPermissions);
        
        if (hasPermission) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}
