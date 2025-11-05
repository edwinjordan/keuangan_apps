# Keuangan Apps - Flutter RBAC Implementation

Aplikasi Flutter dengan implementasi Role-Based Access Control (RBAC) yang lengkap.

## 📋 Fitur

- ✅ **Authentication System**
  - Login dengan email dan password
  - Token-based authentication
  - Secure storage untuk token
  - Auto-login untuk user yang sudah login
  
- ✅ **Role-Based Access Control (RBAC)**
  - User management dengan multiple roles
  - Permission-based access control
  - Dynamic UI berdasarkan role dan permission
  - Helper widgets untuk conditional rendering

- ✅ **State Management**
  - Provider untuk global state
  - Reactive UI updates
  - Clean architecture

## 🏗️ Struktur Proyek

```
lib/
├── main.dart                      # Entry point aplikasi
├── models/                        # Data models
│   ├── user.dart                  # User model dengan RBAC methods
│   ├── role.dart                  # Role model
│   ├── permission.dart            # Permission model
│   └── auth_response.dart         # Auth response model
├── providers/                     # State management
│   └── auth_provider.dart         # Authentication provider
├── screens/                       # UI screens
│   ├── splash_screen.dart         # Splash/loading screen
│   ├── login_screen.dart          # Login screen
│   └── home_screen.dart           # Home/dashboard screen
├── services/                      # Business logic
│   ├── api_service.dart           # HTTP client wrapper
│   └── auth_service.dart          # Authentication service
├── widgets/                       # Reusable widgets
│   ├── role_widget.dart           # Role-based conditional widget
│   └── permission_widget.dart     # Permission-based conditional widget
└── utils/                         # Utilities
    └── constants.dart             # App constants
```

## 🚀 Setup & Installation

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate JSON Serialization Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Konfigurasi Backend API

Edit file `lib/utils/constants.dart` dan sesuaikan `baseUrl`:

```dart
static const String baseUrl = 'http://your-backend-url.com/api/v1';
```

**Catatan untuk Testing Lokal:**
- Android Emulator: `http://10.0.2.2:8000/api/v1`
- iOS Simulator: `http://localhost:8000/api/v1`
- Physical Device: `http://YOUR_COMPUTER_IP:8000/api/v1`

### 4. Run Application

```bash
flutter run
```

## 📱 Penggunaan

### Authentication

```dart
// Login
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.login(
  email: 'user@example.com',
  password: 'password',
);

// Logout
await authProvider.logout();

// Check authentication status
if (authProvider.isAuthenticated) {
  // User is logged in
}
```

### Role-Based Access Control

#### 1. Check User Role

```dart
// Check single role
if (authProvider.hasRole('Admin')) {
  // User is admin
}

// Check multiple roles (any)
if (authProvider.hasAnyRole(['Admin', 'Manager'])) {
  // User is admin or manager
}
```

#### 2. Check User Permission

```dart
// Check single permission
if (authProvider.hasPermission('user_access')) {
  // User has user_access permission
}

// Check multiple permissions (any)
if (authProvider.hasAnyPermission(['user_create', 'user_edit'])) {
  // User has at least one permission
}

// Check multiple permissions (all)
if (authProvider.hasAllPermissions(['user_create', 'user_edit'])) {
  // User has all permissions
}
```

#### 3. Conditional UI with Role Widget

```dart
RoleWidget(
  allowedRoles: const ['Admin', 'Manager'],
  child: ElevatedButton(
    onPressed: () {},
    child: const Text('Admin Only Button'),
  ),
  fallback: const Text('Access Denied'),
)
```

#### 4. Conditional UI with Permission Widget

```dart
PermissionWidget(
  requiredPermissions: const ['user_access'],
  child: ListTile(
    title: const Text('User Management'),
    onTap: () {},
  ),
  fallback: const SizedBox.shrink(),
)

// Require all permissions
PermissionWidget(
  requiredPermissions: const ['user_create', 'user_edit'],
  requireAll: true,
  child: Widget(),
)
```

## 🔐 Security Features

1. **Secure Token Storage**
   - Token disimpan menggunakan `flutter_secure_storage`
   - Otomatis enkripsi di iOS (Keychain) dan Android (KeyStore)

2. **Auto Token Injection**
   - Token otomatis ditambahkan ke setiap API request
   - Managed oleh `ApiService`

3. **Session Management**
   - Auto-login untuk user yang sudah login
   - Token refresh mechanism (jika backend support)

## 📊 Data Models

### User Model

```dart
class User {
  final int id;
  final String name;
  final String email;
  final bool approved;
  final List<Role>? roles;
  
  // Helper methods
  bool hasRole(String roleTitle);
  bool hasAnyRole(List<String> roleTitles);
  bool hasPermission(String permissionTitle);
  bool hasAnyPermission(List<String> permissionTitles);
  bool hasAllPermissions(List<String> permissionTitles);
  Set<String> getAllPermissions();
}
```

### Role Model

```dart
class Role {
  final int id;
  final String title;
  final List<Permission>? permissions;
  
  bool hasPermission(String permissionTitle);
  List<String> getPermissionTitles();
}
```

### Permission Model

```dart
class Permission {
  final int id;
  final String title;
}
```

## 🔌 API Integration

Backend API harus mengikuti struktur berdasarkan dokumentasi RBAC:

### Authentication Endpoints

- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/logout` - Logout
- `GET /api/v1/auth/me` - Get current user
- `POST /api/v1/auth/refresh` - Refresh token

### Expected Response Format

**Login Response:**
```json
{
  "token": "eyJ0eXAiOiJKV1...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "approved": true,
    "roles": [
      {
        "id": 1,
        "title": "Admin",
        "permissions": [
          {
            "id": 1,
            "title": "user_access"
          }
        ]
      }
    ]
  }
}
```

## 🛠️ Customization

### Menambah Screen Baru dengan RBAC

```dart
class MyCustomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Screen')),
      body: Column(
        children: [
          // Show only to Admin
          RoleWidget(
            allowedRoles: const ['Admin'],
            child: AdminPanel(),
          ),
          
          // Show only to users with permission
          PermissionWidget(
            requiredPermissions: const ['feature_access'],
            child: FeatureWidget(),
          ),
        ],
      ),
    );
  }
}
```

### Menambah Custom Permission Check

```dart
// In your custom widget/screen
final authProvider = context.read<AuthProvider>();

if (authProvider.hasPermission('custom_permission')) {
  // Show feature
} else {
  // Show fallback or hide
}
```

## 🐛 Troubleshooting

### Connection Issues

1. Pastikan backend API sudah running
2. Pastikan URL di `constants.dart` sudah benar
3. Untuk Android Emulator gunakan `10.0.2.2` bukan `localhost`
4. Check network permissions di `AndroidManifest.xml`

### Build Runner Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Storage Issues

```bash
# Clear app data (akan menghapus session login)
flutter clean
# Atau uninstall app dari device/emulator
```

## 📚 Resources

- [Dokumentasi RBAC](docs/ROLE_USER_PERMISSION.md)
- [Flutter Provider](https://pub.dev/packages/provider)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## 📝 TODO

- [ ] Implement forgot password
- [ ] Add user profile screen
- [ ] Add role management screen (admin only)
- [ ] Add permission management screen (admin only)
- [ ] Implement refresh token mechanism
- [ ] Add biometric authentication
- [ ] Add offline mode support

## 👨‍💻 Development

### Running Tests

```bash
flutter test
```

### Format Code

```bash
flutter format .
```

### Analyze Code

```bash
flutter analyze
```

## 📄 License

This project is private and confidential.

---

**Created**: November 2025  
**Version**: 1.0.0  
**Flutter Version**: 3.9.2+
