import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/menu_item.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/rbac_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final RbacService _rbacService = RbacService();
  bool _isRefreshingPermissions = false;

  // Define all available menu items with their permissions
  late final List<MenuItem> _allMenuItems;

  @override
  void initState() {
    super.initState();
    _allMenuItems = [
      MenuItem(
        icon: Icons.home,
        label: 'Home',
        route: '/home',
        requiredPermissions: ['home_view'], // From API: home_view permission
      ),
      MenuItem(
        icon: Icons.credit_card,
        label: 'Cards',
        route: '/cards',
        requiredPermissions: ['cards_view'], // From API: cards_view permission
      ),
      MenuItem(
        icon: Icons.account_balance_wallet,
        label: 'Wallet',
        route: '/wallet',
        requiredPermissions: ['wallet_view'], // Wallet permissions
      ),
      MenuItem(
        icon: Icons.bar_chart,
        label: 'Stats',
        route: '/stats',
        requiredPermissions: ['stats_view'], // Statistics permissions
      ),
      MenuItem(
        icon: Icons.person_outline,
        label: 'Profile',
        route: '/profile',
        requiredPermissions: [], // Everyone can access profile
      ),
    ];
    
    // Refresh user permissions from RBAC service on init
    _refreshUserPermissions();
  }

  /// Refresh user permissions from RBAC service
  Future<void> _refreshUserPermissions() async {
    setState(() => _isRefreshingPermissions = true);
    
    try {
      final success = await _authService.refreshUserRolePermissions();
      if (success && mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions refreshed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing permissions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshingPermissions = false);
      }
    }
  }

  /// Show role details from RBAC service
  Future<void> _showRoleDetails(int roleId, String roleTitle) async {
    try {
      final role = await _rbacService.getRoleById(roleId);
      
      if (!mounted) return;
      
      if (role != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Color(0xFF6C63FF)),
                const SizedBox(width: 8),
                Text('Role: ${role.title}'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ID: ${role.id}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Permissions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (role.permissions != null && role.permissions!.isNotEmpty)
                    ...role.permissions!.map((permission) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(permission.title)),
                          Text(
                            'ID: ${permission.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ))
                  else
                    const Text('No permissions assigned'),
                  const SizedBox(height: 16),
                  Text(
                    'Last updated from API',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch role details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get menu items that user has access to
  List<MenuItem> _getAccessibleMenuItems() {
    return _allMenuItems.where((item) {
      return item.hasAccess(
        hasPermission: _authService.hasPermission,
        hasRole: _authService.hasRole,
      );
    }).toList();
  }

  void _onItemTapped(int index) {
    final accessibleItems = _getAccessibleMenuItems();
    if (index >= 0 && index < accessibleItems.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildCurrentContent(User user) {
    final accessibleItems = _getAccessibleMenuItems();
    
    if (_selectedIndex >= accessibleItems.length) {
      _selectedIndex = 0;
    }
    
    final currentItem = accessibleItems[_selectedIndex];
    
    switch (currentItem.route) {
      case '/home':
        return _buildHomeContent(user);
      case '/cards':
        return _buildCardsContent(user);
      case '/wallet':
        return _buildWalletContent(user);
      case '/stats':
        return _buildStatsContent(user);
      case '/profile':
        return _buildProfileContent(user);
      default:
        return _buildHomeContent(user);
    }
  }

  Widget _buildHomeContent(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with greeting and icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${user.name}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Refresh permissions button
                IconButton(
                  icon: _isRefreshingPermissions
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  color: const Color(0xFF6C63FF),
                  onPressed: _isRefreshingPermissions ? null : _refreshUserPermissions,
                  tooltip: 'Refresh Permissions',
                ),
                // RBAC Example Screen button
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  color: const Color(0xFF6C63FF),
                  onPressed: () {
                    Navigator.pushNamed(context, '/rbac-example');
                  },
                  tooltip: 'RBAC Management',
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.grey[700]),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // User Permissions Overview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security, color: Color(0xFF6C63FF), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Access Permissions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.getAllPermissions().map((permission) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Color(0xFF6C63FF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          permission,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9D8CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '\$4,570.80',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Upcoming Payment Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Payment Cards
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPaymentCard(
                context,
                color: const Color(0xFF6C63FF),
                icon: Icons.adobe,
                title: 'Adobe Premium',
                amount: '\$30/month',
                daysLeft: '2 days left',
              ),
              const SizedBox(width: 16),
              _buildPaymentCard(
                context,
                color: Colors.white,
                textColor: Colors.black,
                icon: Icons.apple,
                title: 'Apple Premium',
                amount: '\$30/month',
                daysLeft: '2 days left',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Recent Transactions Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Transaction List
        _buildTransactionItem(
          context,
          icon: Icons.apple,
          title: 'Apple Inc.',
          date: '21 Sep, 03:02 PM',
          amount: '-\$230.50',
          isNegative: true,
        ),
        _buildTransactionItem(
          context,
          icon: Icons.adobe,
          title: 'Adobe',
          date: '21 Sep, 03:22 PM',
          amount: '-\$130.50',
          isNegative: true,
        ),
        _buildTransactionItem(
          context,
          icon: Icons.shopping_bag,
          title: 'Amazon',
          date: '21 Sep, 02:02 PM',
          amount: '-\$20.50',
          isNegative: true,
        ),
      ],
    );
  }

  Widget _buildCardsContent(User user) {
    // Check user permissions for cards
    final canView = _authService.hasPermission('cards_view');
    final canEdit = _authService.hasPermission('cards_edit');
    final canCreate = _authService.hasPermission('cards_create');
    final canShow = _authService.hasPermission('cards_show');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cards',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Show create button only if user has cards_create permission
              if (canCreate)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Create new card')),
                    );
                  },
                  color: const Color(0xFF6C63FF),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Permission indicators
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Card Permissions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPermissionRow('View Cards', canView),
                _buildPermissionRow('Show Card Details', canShow),
                _buildPermissionRow('Edit Cards', canEdit),
                _buildPermissionRow('Create Cards', canCreate),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cards content based on permissions
          if (canView) ...[
            const Text(
              'Your Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCardItem(
              context,
              cardType: 'Visa',
              cardNumber: '•••• 4242',
              balance: '\$2,450.00',
              canEdit: canEdit,
              canShow: canShow,
            ),
            const SizedBox(height: 12),
            _buildCardItem(
              context,
              cardType: 'Mastercard',
              cardNumber: '•••• 8888',
              balance: '\$1,320.80',
              canEdit: canEdit,
              canShow: canShow,
            ),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No permission to view cards',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String label, bool hasPermission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: hasPermission ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: hasPermission ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context, {
    required String cardType,
    required String cardNumber,
    required String balance,
    required bool canEdit,
    required bool canShow,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9D8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Show details button - only if user has cards_show permission
                  if (canShow)
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Show $cardType details')),
                        );
                      },
                    ),
                  // Edit button - only if user has cards_edit permission
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Edit $cardType')),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            cardNumber,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletContent(User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Wallet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View all your transactions',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View your financial statistics',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF6C63FF),
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              if (user.roles != null && user.roles!.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Roles:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...user.roles!.map((role) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _showRoleDetails(role.id, role.title),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings,
                              color: Color(0xFF6C63FF),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.title,
                                    style: const TextStyle(
                                      color: Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${role.permissions?.length ?? 0} permissions',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF6C63FF),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;

            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildCurrentContent(user),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final accessibleItems = _getAccessibleMenuItems();
          
          // BottomNavigationBar requires at least 2 items
          // If user has less than 2 accessible items, don't show the bar
          if (accessibleItems.length < 2) {
            return const SizedBox.shrink();
          }
          
          // Ensure selected index is within bounds
          if (_selectedIndex >= accessibleItems.length) {
            _selectedIndex = 0;
          }
          
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            items: accessibleItems.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: _authService.hasPermission('cards_create')
          ? FloatingActionButton(
              onPressed: () {
                // Add new card/transaction
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create new card')),
                );
              },
              backgroundColor: const Color(0xFF6C63FF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPaymentCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String amount,
    required String daysLeft,
    Color textColor = Colors.white,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: textColor == Colors.white
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: textColor,
                  size: 24,
                ),
              ),
              Icon(
                Icons.more_vert,
                color: textColor,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                daysLeft,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required bool isNegative,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isNegative ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
