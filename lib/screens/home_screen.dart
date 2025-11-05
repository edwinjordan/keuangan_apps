import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/menu_item.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

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
        requiredPermissions: ['dashboard_access'],
      ),
      MenuItem(
        icon: Icons.credit_card,
        label: 'Cards',
        route: '/cards',
        requiredPermissions: ['view_cards'],
      ),
      MenuItem(
        icon: Icons.account_balance_wallet,
        label: 'Wallet',
        route: '/wallet',
        requiredPermissions: ['view_transactions'],
      ),
      MenuItem(
        icon: Icons.bar_chart,
        label: 'Stats',
        route: '/stats',
        requiredPermissions: ['view_statistics'],
      ),
      MenuItem(
        icon: Icons.person_outline,
        label: 'Profile',
        route: '/profile',
        requiredPermissions: [], // Everyone can access profile
      ),
    ];
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Cards Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View and manage your cards',
            style: TextStyle(color: Colors.grey[500]),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Roles:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: user.roles!.map((role) {
                        return Chip(
                          label: Text(role.title),
                          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
      floatingActionButton: _authService.hasPermission('create_transaction')
          ? FloatingActionButton(
              onPressed: () {
                // Add transaction
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Transaction')),
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
