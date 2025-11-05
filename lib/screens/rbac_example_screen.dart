import 'package:flutter/material.dart';
import '../models/role.dart';
import '../models/permission.dart';
import '../services/rbac_service.dart';
import '../services/auth_service.dart';

/// Example screen demonstrating RBAC functionality
/// Shows how to fetch and display roles and permissions
class RbacExampleScreen extends StatefulWidget {
  const RbacExampleScreen({Key? key}) : super(key: key);

  @override
  State<RbacExampleScreen> createState() => _RbacExampleScreenState();
}

class _RbacExampleScreenState extends State<RbacExampleScreen> {
  final RbacService _rbacService = RbacService();
  final AuthService _authService = AuthService();
  
  Role? _selectedRole;
  List<Role> _allRoles = [];
  List<Permission> _allPermissions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all roles and permissions
      final roles = await _rbacService.getAllRoles();
      final permissions = await _rbacService.getAllPermissions();
      
      setState(() {
        _allRoles = roles;
        _allPermissions = permissions;
      });
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRoleById(int roleId) async {
    setState(() => _isLoading = true);
    
    try {
      final role = await _rbacService.getRoleById(roleId);
      
      setState(() {
        _selectedRole = role;
      });
      
      if (role != null) {
        _showSuccess('Role "${role.title}" loaded successfully!');
      }
    } catch (e) {
      _showError('Failed to load role: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshUserPermissions() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _authService.refreshUserRolePermissions();
      
      if (success) {
        _showSuccess('User permissions refreshed successfully!');
      } else {
        _showError('Failed to refresh user permissions');
      }
    } catch (e) {
      _showError('Error refreshing permissions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RBAC Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  
                  // Current User Info
                  _buildCurrentUserInfo(),
                  const SizedBox(height: 24),
                  
                  // Selected Role Details
                  if (_selectedRole != null) ...[
                    _buildSelectedRoleCard(),
                    const SizedBox(height: 24),
                  ],
                  
                  // All Roles List
                  _buildAllRolesList(),
                  const SizedBox(height: 24),
                  
                  // All Permissions List
                  _buildAllPermissionsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _loadRoleById(1),
                  icon: const Icon(Icons.download),
                  label: const Text('Load Admin Role'),
                ),
                ElevatedButton.icon(
                  onPressed: _refreshUserPermissions,
                  icon: const Icon(Icons.sync),
                  label: const Text('Refresh User Permissions'),
                ),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.list),
                  label: const Text('Load All Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentUserInfo() {
    final user = _authService.currentUser;
    
    if (user == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No user logged in'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current User',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Name: ${user.name}'),
            Text('Email: ${user.email}'),
            Text('Roles: ${user.roles?.map((r) => r.title).join(', ') ?? 'None'}'),
            const SizedBox(height: 8),
            if (user.roles != null && user.roles!.isNotEmpty) ...[
              const Text(
                'Permissions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...user.getAllPermissions().map(
                (permissionTitle) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(permissionTitle),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedRoleCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Selected Role: ${_selectedRole!.title}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('ID: ${_selectedRole!.id}'),
            const SizedBox(height: 8),
            const Text(
              'Permissions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (_selectedRole!.permissions != null && _selectedRole!.permissions!.isNotEmpty)
              ...(_selectedRole!.permissions!.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.security, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p.title)),
                      Text(
                        'ID: ${p.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
            else
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 4),
                child: Text('No permissions'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRolesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Roles (${_allRoles.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_allRoles.isEmpty)
              const Text('No roles loaded')
            else
              ..._allRoles.map(
                (role) => ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(role.title),
                  subtitle: Text(
                    'ID: ${role.id} | Permissions: ${role.permissions?.length ?? 0}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _loadRoleById(role.id),
                  ),
                  onTap: () => _loadRoleById(role.id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPermissionsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Permissions (${_allPermissions.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_allPermissions.isEmpty)
              const Text('No permissions loaded')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allPermissions.map(
                  (permission) => Chip(
                    avatar: const Icon(Icons.vpn_key, size: 16),
                    label: Text(permission.title),
                  ),
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
