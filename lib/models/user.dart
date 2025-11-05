import 'package:json_annotation/json_annotation.dart';
import 'role.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;
  final bool approved;
  final List<Role>? roles;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.approved = false,
    this.roles,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Check if user has a specific role
  bool hasRole(String roleTitle) {
    if (roles == null) return false;
    return roles!.any((r) => r.title == roleTitle);
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roleTitles) {
    if (roles == null) return false;
    return roles!.any((r) => roleTitles.contains(r.title));
  }

  /// Check if user has a specific permission through their roles
  bool hasPermission(String permissionTitle) {
    if (roles == null) return false;
    for (var role in roles!) {
      if (role.hasPermission(permissionTitle)) {
        return true;
      }
    }
    return false;
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissionTitles) {
    for (var permission in permissionTitles) {
      if (hasPermission(permission)) {
        return true;
      }
    }
    return false;
  }

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> permissionTitles) {
    for (var permission in permissionTitles) {
      if (!hasPermission(permission)) {
        return false;
      }
    }
    return true;
  }

  /// Get all role titles for this user
  List<String> getRoleTitles() {
    if (roles == null) return [];
    return roles!.map((r) => r.title).toList();
  }

  /// Get all permission titles from all roles
  Set<String> getAllPermissions() {
    if (roles == null) return {};
    Set<String> permissions = {};
    for (var role in roles!) {
      permissions.addAll(role.getPermissionTitles());
    }
    return permissions;
  }

  /// Check if user is approved
  bool get isApproved => approved;

  /// Check if email is verified
  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, roles: ${roles?.length ?? 0})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
