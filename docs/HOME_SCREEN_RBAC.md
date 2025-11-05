# RBAC Implementation in Home Screen

## Overview
The Home Screen now implements full RBAC (Role-Based Access Control) integration with your API endpoint `http://127.0.0.1:8000/api/v1/roles/{id}`.

## Permissions Used

Based on your API response, the following permissions are implemented:

### Navigation Permissions
- `home_view` - Access to Home screen
- `cards_view` - Access to Cards section
- `wallet_view` - Access to Wallet section
- `stats_view` - Access to Statistics section
- Profile - No permission required (accessible to all)

### Card Management Permissions
- `cards_view` - View cards list
- `cards_show` - Show individual card details
- `cards_edit` - Edit card information
- `cards_create` - Create new cards

## Implementation Details

### 1. Dynamic Bottom Navigation
The bottom navigation bar only shows menu items that the user has permission to access:

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

**Result:** Users only see navigation items they can access.

### 2. Permission-Based Cards Section
The Cards section adapts based on user permissions:

#### View Permission (`cards_view`)
- Shows/hides card list
- If missing: Shows "No permission to view cards" message

#### Show Permission (`cards_show`)
- Enables "View Details" button on cards
- If missing: Button is hidden

#### Edit Permission (`cards_edit`)
- Enables "Edit" button on cards
- If missing: Button is hidden

#### Create Permission (`cards_create`)
- Shows floating action button to create new cards
- Shows "+" button in Cards header
- If missing: Both buttons are hidden

### 3. Permission Indicators
The Cards section displays a visual indicator showing which permissions the user has:

```dart
Container(
  child: Column(
    children: [
      Text('Your Card Permissions:'),
      _buildPermissionRow('View Cards', canView),
      _buildPermissionRow('Show Card Details', canShow),
      _buildPermissionRow('Edit Cards', canEdit),
      _buildPermissionRow('Create Cards', canCreate),
    ],
  ),
)
```

**Result:** Users can see their exact permissions at a glance.

### 4. Home Screen Permission Display
The home screen shows all permissions the user has:

```dart
Wrap(
  children: user.getAllPermissions().map((permission) {
    return Chip(
      label: Text(permission),
      // Styled chip showing permission name
    );
  }).toList(),
)
```

**Result:** Complete transparency of user permissions.

### 5. RBAC Management Access
A button in the home screen header provides quick access to the RBAC Example Screen:

```dart
IconButton(
  icon: Icon(Icons.admin_panel_settings),
  onPressed: () {
    Navigator.pushNamed(context, '/rbac-example');
  },
  tooltip: 'RBAC Management',
)
```

**Result:** Easy access to test and manage RBAC features.

## User Experience Flow

### Scenario 1: Admin User (All Permissions)
```
API Response:
- home_view ✓
- cards_view ✓
- cards_edit ✓
- cards_show ✓
- cards_create ✓

User sees:
✓ All 5 navigation items
✓ Full card list
✓ View, Edit buttons on all cards
✓ Create card button (FAB and header)
✓ All permissions displayed
```

### Scenario 2: Limited User (View Only)
```
API Response:
- home_view ✓
- cards_view ✓

User sees:
✓ Home, Cards, Profile navigation items
✓ Card list (read-only)
✗ No Edit/View Details buttons
✗ No Create button
✓ Permission indicators show limited access
```

### Scenario 3: No Card Access
```
API Response:
- home_view ✓

User sees:
✓ Home, Profile navigation items
✗ Cards menu item hidden
✓ If somehow accessing Cards: "No permission" message
✓ Clear permission indicators
```

## Code Examples

### Check Permission Before Action
```dart
if (_authService.hasPermission('cards_edit')) {
  // Show edit button
  IconButton(
    icon: Icon(Icons.edit),
    onPressed: () => editCard(),
  )
}
```

### Conditional Button Rendering
```dart
// Create button - only if user has cards_create permission
if (canCreate)
  IconButton(
    icon: Icon(Icons.add_circle_outline),
    onPressed: () => createCard(),
  )
```

### Permission Row Display
```dart
Widget _buildPermissionRow(String label, bool hasPermission) {
  return Row(
    children: [
      Icon(
        hasPermission ? Icons.check_circle : Icons.cancel,
        color: hasPermission ? Colors.green : Colors.red,
      ),
      Text(label),
    ],
  );
}
```

## Testing

### 1. Test with Admin Role (ID: 1)
```bash
# Ensure backend returns all permissions for role ID 1
GET http://127.0.0.1:8000/api/v1/roles/1
```

Expected behavior:
- All menu items visible
- All card actions available
- FAB visible

### 2. Test with Limited Permissions
Modify user's role to have only `cards_view` permission.

Expected behavior:
- Cards menu visible
- Cards displayed but read-only
- No edit/create buttons

### 3. Test Permission Refresh
```dart
await _authService.refreshUserRolePermissions();
```

Expected behavior:
- UI updates to reflect new permissions
- Navigation items adjust
- Card actions update

## Visual Indicators

### Permission Chips (Home Screen)
- **Green check icon** - Permission granted
- **Purple background** - Active permission
- **Wrapped layout** - All permissions visible

### Permission Rows (Cards Section)
- **Green check** - Has permission
- **Red X** - Missing permission
- **Grayed text** - Disabled feature

### Locked State
- **Lock icon** - No access
- **Gray color scheme** - Feature unavailable
- **Clear message** - "No permission to view cards"

## Security Features

1. **Client-Side Checks**: Fast UI updates
2. **Server Validation**: All API calls validated server-side
3. **Fail-Closed**: Default deny for missing permissions
4. **Real-Time Sync**: Refresh permissions from server
5. **Visual Feedback**: Users always know their access level

## Benefits

### For Users
- ✅ Clear understanding of their permissions
- ✅ No confusion about why features are missing
- ✅ Clean, focused interface showing only what they can use

### For Administrators
- ✅ Granular control over feature access
- ✅ Easy to manage via API
- ✅ Immediate effect when permissions change

### For Developers
- ✅ Consistent permission checking
- ✅ Reusable permission widgets
- ✅ Easy to add new features with permissions
- ✅ Well-documented and tested

## Next Steps

1. **Add more sections**: Implement RBAC for Wallet and Stats sections
2. **Error handling**: Add retry logic for permission fetch failures
3. **Offline mode**: Cache permissions for offline access
4. **Audit logging**: Track permission usage
5. **Admin UI**: Build interface for role/permission management

## Related Files

- `lib/screens/home_screen.dart` - Main implementation
- `lib/services/rbac_service.dart` - RBAC service
- `lib/services/auth_service.dart` - Auth with permissions
- `lib/models/menu_item.dart` - Menu with permissions
- `lib/screens/rbac_example_screen.dart` - Testing interface
- `docs/RBAC_USAGE.md` - Complete usage guide

## API Integration

The home screen integrates with your API endpoint:
```
GET http://127.0.0.1:8000/api/v1/roles/1
```

Response used:
```json
{
  "success": true,
  "data": {
    "permissions": [
      {"id": 1, "title": "home_view"},
      {"id": 2, "title": "cards_view"},
      {"id": 3, "title": "cards_edit"},
      {"id": 4, "title": "cards_show"},
      {"id": 4, "title": "cards_create"}
    ]
  }
}
```

All permissions are automatically synced and applied to the UI.
