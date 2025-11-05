# Keuangan Apps

Aplikasi manajemen keuangan dengan sistem **Role-Based Access Control (RBAC)** yang lengkap menggunakan Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-3.0-blue)
![License](https://img.shields.io/badge/License-Private-red)

## ✨ Features

- 🔐 **Authentication System**
  - Login dengan email & password
  - Token-based authentication (JWT)
  - Auto-login untuk returning users
  - Secure token storage

- 👥 **Role-Based Access Control (RBAC)**
  - Multi-role support untuk setiap user
  - Permission-based access control
  - Dynamic UI berdasarkan role & permission
  - Helper widgets untuk conditional rendering

- 🎨 **Modern UI/UX**
  - Material Design 3
  - Responsive layout
  - Clean & intuitive interface
  - Loading states & error handling

- 🏗️ **Clean Architecture**
  - Separation of concerns
  - Provider state management
  - Service layer untuk business logic
  - Reusable widgets & utilities

## 📸 Screenshots

_Coming soon..._

## 🚀 Quick Start

### Prerequisites

- Flutter SDK ≥ 3.9.2
- Dart SDK ≥ 3.0
- Backend API dengan RBAC support

### Installation

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd keuangan_apps
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure backend URL**
   
   Edit `lib/utils/constants.dart`:
   ```dart
   static const String baseUrl = 'http://your-api-url.com/api/v1';
   ```

5. **Run application**
   ```bash
   flutter run
   ```

## 📚 Documentation

- [📖 Implementation Guide](docs/IMPLEMENTATION_GUIDE.md) - Panduan lengkap implementasi
- [⚡ Quick Start Guide](docs/QUICK_START.md) - Mulai cepat untuk developer
- [🔐 RBAC Documentation](docs/ROLE_USER_PERMISSION.md) - Dokumentasi struktur RBAC
- [🧪 API Testing Guide](docs/API_TESTING.md) - Panduan testing API

## 🏗️ Project Structure

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
│   ├── user.dart               # User model dengan RBAC methods
│   ├── role.dart               # Role model
│   ├── permission.dart         # Permission model
│   └── auth_response.dart      # Auth response
├── providers/                   # State management
│   └── auth_provider.dart      # Authentication state
├── screens/                     # UI Screens
│   ├── splash_screen.dart      # Splash screen
│   ├── login_screen.dart       # Login screen
│   └── home_screen.dart        # Dashboard
├── services/                    # Business logic
│   ├── api_service.dart        # HTTP client
│   └── auth_service.dart       # Auth service
├── widgets/                     # Reusable widgets
│   ├── role_widget.dart        # Role-based widget
│   └── permission_widget.dart  # Permission-based widget
└── utils/                       # Utilities
    ├── constants.dart          # App constants
    ├── helpers.dart            # Helper functions
    └── app_theme.dart          # Theme config
```

## 💡 Usage Examples

### Check User Role

```dart
final authProvider = context.read<AuthProvider>();

if (authProvider.hasRole('Admin')) {
  // User is admin
}

if (authProvider.hasAnyRole(['Admin', 'Manager'])) {
  // User is admin or manager
}
```

### Check User Permission

```dart
if (authProvider.hasPermission('user_access')) {
  // User can access user management
}

if (authProvider.hasAllPermissions(['user_create', 'user_edit'])) {
  // User has all permissions
}
```

### Role-Based Widget

```dart
RoleWidget(
  allowedRoles: const ['Admin'],
  child: AdminDashboard(),
  fallback: Text('Access Denied'),
)
```

### Permission-Based Widget

```dart
PermissionWidget(
  requiredPermissions: const ['user_access'],
  child: UserManagementScreen(),
  fallback: SizedBox.shrink(),
)
```

## 🔧 Configuration

### Backend URL Setup

**Development (Android Emulator):**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
```

**Development (iOS Simulator):**
```dart
static const String baseUrl = 'http://localhost:8000/api/v1';
```

**Production:**
```dart
static const String baseUrl = 'https://api.yourdomain.com/api/v1';
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📦 Dependencies

Main dependencies:
- `provider: ^6.1.1` - State management
- `http: ^1.1.0` - HTTP client
- `flutter_secure_storage: ^9.0.0` - Secure storage
- `shared_preferences: ^2.2.2` - Local storage
- `json_annotation: ^4.8.1` - JSON serialization

Dev dependencies:
- `build_runner: ^2.4.7` - Code generation
- `json_serializable: ^6.7.1` - JSON code generator

## 🐛 Troubleshooting

### Connection Issues

- ✅ Pastikan backend API running
- ✅ Gunakan `10.0.2.2` untuk Android Emulator (bukan localhost)
- ✅ Check network permissions di AndroidManifest.xml

### Build Issues

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🤝 Contributing

This is a private project. For contribution guidelines, please contact the project maintainer.

## 📄 License

This project is proprietary and confidential.

## 👨‍💻 Developer

**Project**: Keuangan Apps  
**Created**: November 2025  
**Version**: 1.0.0

---

For detailed documentation, see [docs/](docs/) folder.
