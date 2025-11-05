# RBAC Implementation - Dynamic Bottom Navigation

## Overview
Implementasi Role-Based Access Control (RBAC) untuk bottom navigation bar yang dinamis berdasarkan permission user.

## Fitur

### 1. Dynamic Bottom Navigation
Bottom navigation bar sekarang menampilkan menu secara dinamis berdasarkan permission yang dimiliki user:

- **Home** - Requires: `dashboard_access`
- **Cards** - Requires: `view_cards`
- **Wallet** - Requires: `view_transactions`
- **Stats** - Requires: `view_statistics`
- **Profile** - No permission required (accessible by all)

### 2. Floating Action Button (FAB)
- **Removed**: Tombol barcode scanner telah dihapus
- **Added**: FAB untuk menambah transaksi (hanya muncul jika user memiliki permission `create_transaction`)
- **Position**: EndFloat (pojok kanan bawah)

### 3. Multiple Content Views
Aplikasi sekarang mendukung multiple views:
- **Home**: Dashboard utama dengan balance card, upcoming payments, dan recent transactions
- **Cards**: Halaman manajemen kartu
- **Wallet**: Halaman transaksi wallet
- **Stats**: Halaman statistik keuangan
- **Profile**: Halaman profil user dengan info role dan tombol logout

## Struktur File

### Models
- `lib/models/menu_item.dart` - Model untuk menu item dengan RBAC support

### Services
- `lib/services/auth_service.dart` - Updated dengan dummy user yang memiliki full permissions

### Screens
- `lib/screens/home_screen.dart` - Refactored dengan dynamic navigation dan multiple views

## Permissions

### Default User Permissions (Dummy User)
```dart
[
  'dashboard_access',      // View home/dashboard
  'view_transactions',     // View wallet/transactions
  'view_cards',           // View cards
  'view_statistics',      // View statistics
  'create_transaction',   // Create new transaction (shows FAB)
]
```

### Adding More Permissions
1. Define permission in backend
2. Add to user's role permissions
3. Check permission in code:
   ```dart
   if (_authService.hasPermission('permission_name')) {
     // Show feature
   }
   ```

## How It Works

### 1. Menu Filtering
```dart
List<MenuItem> _getAccessibleMenuItems() {
  return _allMenuItems.where((item) {
    return item.hasAccess(
      hasPermission: _authService.hasPermission,
      hasRole: _authService.hasRole,
    );
  }).toList();
}
```

### 2. Dynamic Content
```dart
Widget _buildCurrentContent(User user) {
  final currentItem = accessibleItems[_selectedIndex];
  
  switch (currentItem.route) {
    case '/home': return _buildHomeContent(user);
    case '/cards': return _buildCardsContent(user);
    // ... etc
  }
}
```

### 3. Conditional FAB
```dart
floatingActionButton: _authService.hasPermission('create_transaction')
    ? FloatingActionButton(...)
    : null,
```

## Testing Different Roles

### Test with Limited Permissions
Update `_createDummyUser()` in `auth_service.dart`:

```dart
// User with limited access (only home and profile)
Permission(id: 1, title: 'dashboard_access'),
// Remove other permissions to test
```

### Test with Full Admin Access
```dart
// Add all permissions including admin-specific ones
Permission(id: 1, title: 'dashboard_access'),
Permission(id: 2, title: 'view_transactions'),
Permission(id: 3, title: 'view_cards'),
Permission(id: 4, title: 'view_statistics'),
Permission(id: 5, title: 'create_transaction'),
Permission(id: 6, title: 'admin_panel'),
Permission(id: 7, title: 'manage_users'),
```

## Future Improvements

1. **Backend Integration**
   - Replace dummy user dengan real user data dari `/auth/me`
   - Sync permissions dari backend

2. **Role-Based UI**
   - Show/hide features based on roles
   - Different dashboard layouts for different roles

3. **Permission Cache**
   - Cache permissions di local storage
   - Refresh on user data update

4. **Audit Log**
   - Track permission checks
   - Log access attempts

## Security Notes

⚠️ **Important**: 
- Permission check hanya di client side
- Backend MUST validate permissions pada setiap API call
- Never trust client-side permission checks for security
- Always implement server-side authorization

## Screenshots

### Full Access User
- Sees all 5 menu items: Home, Cards, Wallet, Stats, Profile
- FAB visible for adding transactions

### Limited Access User
- Only sees menu items they have permission for
- FAB hidden if no `create_transaction` permission
- Profile always accessible

## API Integration

When backend `/auth/me` is ready, user permissions will automatically load:

```dart
final user = await getCurrentUser();
// Permissions loaded from user.roles[].permissions[]
```

Dummy user only used as fallback when endpoint returns 404.
