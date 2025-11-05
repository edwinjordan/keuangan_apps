# Flutter RBAC App - Quick Start Guide

## Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.0 or higher
- Backend API yang sudah implement RBAC (lihat ROLE_USER_PERMISSION.md)

## Installation Steps

### 1. Clone & Install Dependencies

```bash
cd keuangan_apps
flutter pub get
```

### 2. Generate JSON Serialization Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Setup Backend URL

Edit `lib/utils/constants.dart` line 3:

```dart
static const String baseUrl = 'http://your-backend-url.com/api/v1';
```

**Testing Lokal:**
- **Android Emulator:** `http://10.0.2.2:8000/api/v1`
- **iOS Simulator:** `http://localhost:8000/api/v1`  
- **Physical Device:** `http://192.168.x.x:8000/api/v1` (ganti dengan IP komputer)

### 4. Run App

```bash
flutter run
```

## Testing Login

Gunakan kredensial test dari backend Anda:

```
Email: admin@example.com
Password: password
```

## Struktur File Penting

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models dengan RBAC
├── providers/               # State management (Provider)
├── screens/                 # UI Screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   └── home_screen.dart
├── services/                # Business logic
│   ├── api_service.dart
│   └── auth_service.dart
├── widgets/                 # Reusable widgets
│   ├── role_widget.dart
│   └── permission_widget.dart
└── utils/
    └── constants.dart       # Configuration
```

## Fitur RBAC

### 1. Check Role in Code

```dart
final authProvider = context.read<AuthProvider>();

if (authProvider.hasRole('Admin')) {
  // User is admin
}
```

### 2. Check Permission

```dart
if (authProvider.hasPermission('user_access')) {
  // User can access user management
}
```

### 3. Conditional Widget (Role)

```dart
RoleWidget(
  allowedRoles: const ['Admin'],
  child: Text('Admin Only Content'),
  fallback: Text('Access Denied'),
)
```

### 4. Conditional Widget (Permission)

```dart
PermissionWidget(
  requiredPermissions: const ['user_create'],
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Create User'),
  ),
)
```

## Common Issues

### ❌ Connection Refused / Network Error

**Solusi:**
1. Pastikan backend running
2. Check URL di `constants.dart`
3. Untuk Android Emulator gunakan `10.0.2.2` bukan `localhost`
4. Tambahkan permission di `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

### ❌ Build Error pada Models

**Solusi:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ Token Not Saved / Auto Login Tidak Bekerja

**Solusi:**
- Uninstall app dari device/emulator
- Install ulang

## Next Steps

1. ✅ Setup backend API
2. ✅ Configure base URL
3. ✅ Test login
4. ✅ Test RBAC features
5. 📝 Customize sesuai kebutuhan

## Support

Lihat dokumentasi lengkap:
- [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) - Panduan lengkap
- [ROLE_USER_PERMISSION.md](ROLE_USER_PERMISSION.md) - Database structure

---

Happy Coding! 🚀
