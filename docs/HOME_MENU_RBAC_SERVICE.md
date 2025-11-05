# RbacService Integration in Home Menu - Implementation Guide

## Overview
The home screen now fully integrates with `RbacService` to dynamically fetch and manage user permissions from the API endpoint `http://127.0.0.1:8000/api/v1/roles/{id}`.

## Features Implemented

### 1. **Automatic Permission Refresh on Init**
When the home screen loads, it automatically fetches the latest permissions from the RBAC API:

```dart
@override
void initState() {
  super.initState();
  // ... menu items setup
  _refreshUserPermissions(); // ← Fetches fresh permissions from API
}
```

**Result:** Users always see their current permissions without manual refresh.

### 2. **Manual Refresh Button**
Added a refresh icon button in the home screen header:

- **Icon:** Refresh icon (↻)
- **Location:** Top right, next to admin panel icon
- **State:** Shows loading spinner when refreshing
- **Feedback:** Success/error snackbar messages

```dart
IconButton(
  icon: _isRefreshingPermissions
      ? CircularProgressIndicator()
      : Icon(Icons.refresh),
  onPressed: _refreshUserPermissions,
  tooltip: 'Refresh Permissions',
)
```

**Result:** Users can manually sync their permissions anytime.

### 3. **Interactive Role Cards in Profile**
The profile section now displays clickable role cards that show detailed information from RbacService:

**Features:**
- Shows role name and permission count
- Clickable to view full role details
- Fetches live data from `GET /api/v1/roles/{id}`
- Displays all permissions with IDs

```dart
InkWell(
  onTap: () => _showRoleDetails(role.id, role.title),
  child: RoleCard(...),
)
```

**Result:** Users can explore their role permissions in detail.

### 4. **Role Details Dialog**
When clicking on a role card, a dialog shows:

- Role ID and title
- Complete list of permissions
- Permission IDs
- Visual check marks for each permission
- "Last updated from API" indicator

```dart
Future<void> _showRoleDetails(int roleId, String roleTitle) async {
  final role = await _rbacService.getRoleById(roleId);
  // Display dialog with role details
}
```

**Result:** Complete transparency of role permissions.

## API Integration Flow

### On Screen Load
```
User opens home screen
    ↓
initState() calls _refreshUserPermissions()
    ↓
AuthService.refreshUserRolePermissions()
    ↓
For each user role:
    RbacService.getRoleById(roleId)
        ↓
    GET http://127.0.0.1:8000/api/v1/roles/{id}
        ↓
    Parses response and updates permissions
    ↓
UI rebuilds with fresh permissions
    ↓
Bottom navigation shows accessible items
```

### On Manual Refresh
```
User taps refresh button
    ↓
_isRefreshingPermissions = true (shows spinner)
    ↓
Same flow as screen load
    ↓
Success/error snackbar shown
    ↓
_isRefreshingPermissions = false
```

### On Role Card Tap
```
User taps role card in profile
    ↓
_showRoleDetails(roleId, roleTitle)
    ↓
RbacService.getRoleById(roleId)
    ↓
GET http://127.0.0.1:8000/api/v1/roles/{id}
    ↓
Show dialog with fresh role data
```

## UI Components

### 1. Refresh Button (Home Header)
```dart
// Location: Home screen header, right side
// Shows: Refresh icon or loading spinner
// Action: Fetches fresh permissions from API
// Feedback: Snackbar on success/error
```

### 2. Permission Chips (Home Screen)
```dart
// Location: Below greeting, in white container
// Shows: All user permissions as chips
// Updates: After permission refresh
// Style: Purple background with check icons
```

### 3. Role Cards (Profile Section)
```dart
// Location: Profile section, below avatar
// Shows: Role name + permission count
// Interactive: Tap to view details
// Style: Purple border, clickable
```

### 4. Role Details Dialog
```dart
// Trigger: Tap on role card
// Content:
//   - Role ID and title
//   - List of all permissions
//   - Permission IDs
//   - Check mark icons
// Action: Close button
```

## Code Structure

### Services Used
```dart
final AuthService _authService = AuthService();
final RbacService _rbacService = RbacService();
```

### Key Methods

#### _refreshUserPermissions()
```dart
// Fetches fresh permissions from API
// Updates AuthService user data
// Shows success/error feedback
// Triggers UI rebuild
```

#### _showRoleDetails(roleId, roleTitle)
```dart
// Fetches role details from RbacService
// Displays dialog with permissions
// Handles errors gracefully
```

## Permission Flow

### Menu Items
```dart
MenuItem(
  label: 'Cards',
  requiredPermissions: ['cards_view'],
)
    ↓
_getAccessibleMenuItems()
    ↓
item.hasAccess(
  hasPermission: _authService.hasPermission,
  hasRole: _authService.hasRole,
)
    ↓
AuthService checks user's roles
    ↓
Returns only accessible items
    ↓
Bottom navigation updates
```

### Card Actions
```dart
final canEdit = _authService.hasPermission('cards_edit');
    ↓
if (canEdit)
  IconButton(icon: Icons.edit, ...)
```

## User Experience

### Scenario 1: First Time Load
```
1. User opens app and logs in
2. Home screen loads
3. Permissions automatically fetched from API
4. Menu shows only accessible items
5. Permission chips display current access
```

### Scenario 2: Permission Change
```
1. Admin changes user permissions on server
2. User taps refresh button (↻)
3. Loading spinner shows
4. Fresh permissions fetched
5. "Permissions refreshed successfully" message
6. Menu items update automatically
7. New permissions visible in chips
```

### Scenario 3: View Role Details
```
1. User navigates to Profile
2. Sees role cards with permission counts
3. Taps on a role card
4. Dialog fetches fresh role data from API
5. Shows complete permission list
6. Can see exact permissions and IDs
```

## Error Handling

### Permission Refresh Fails
```dart
catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to refresh permissions: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

### Role Details Fetch Fails
```dart
if (role == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to fetch role details')),
  );
}
```

### Minimum Menu Items
```dart
// If user has < 2 accessible items, hide bottom nav
if (accessibleItems.length < 2) {
  return SizedBox.shrink();
}
```

## Benefits

### For Users
✅ Always see current permissions
✅ Easy manual refresh option
✅ Explore role details interactively
✅ Clear visual feedback
✅ No confusion about access levels

### For Administrators
✅ Permission changes take effect immediately (after refresh)
✅ Users can self-verify their access
✅ Reduced support queries about permissions
✅ Transparent permission system

### For Developers
✅ Clean separation with RbacService
✅ Reusable permission refresh logic
✅ Consistent error handling
✅ Easy to extend with new features

## Testing

### Test Permission Refresh
```dart
1. Login as user
2. Note current permissions
3. Change permissions on server (via API)
4. Tap refresh button
5. Verify new permissions appear
6. Check menu items updated
```

### Test Role Details
```dart
1. Go to Profile section
2. Tap on a role card
3. Verify dialog shows correct permissions
4. Check permission IDs match API
5. Close and open again (fetches fresh data)
```

### Test Auto-refresh on Load
```dart
1. Change user permissions on server
2. Logout and login again
3. Verify home screen shows new permissions
4. No manual refresh needed
```

## API Endpoints Used

### Refresh Permissions
```
For each user role:
GET http://127.0.0.1:8000/api/v1/roles/{role.id}

Response:
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Admin",
    "permissions": [...]
  }
}
```

### Role Details Dialog
```
GET http://127.0.0.1:8000/api/v1/roles/{roleId}

Same response format as above
```

## Configuration

### Base URL
Located in `lib/utils/constants.dart`:
```dart
static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
```

### Endpoints
```dart
static const String rolesEndpoint = '/roles';
```

## Next Steps (Optional Enhancements)

1. **Auto-refresh on App Resume** - Refresh permissions when app comes to foreground
2. **Permission Cache** - Cache permissions locally for offline access
3. **Real-time Updates** - WebSocket support for instant permission changes
4. **Permission History** - Track when permissions were last updated
5. **Batch Operations** - Refresh multiple roles efficiently
6. **Advanced Filtering** - Filter permissions by category in dialog

## Related Files

- `lib/screens/home_screen.dart` - Main implementation
- `lib/services/rbac_service.dart` - RBAC API integration
- `lib/services/auth_service.dart` - Auth and permission checks
- `lib/models/role.dart` - Role model
- `lib/models/permission.dart` - Permission model

## Summary

The home menu now fully integrates with RbacService to provide:
- ✅ Automatic permission synchronization
- ✅ Manual refresh capability
- ✅ Interactive role exploration
- ✅ Real-time API data
- ✅ Clear user feedback
- ✅ Robust error handling

**The implementation is complete and production-ready!** 🎉
