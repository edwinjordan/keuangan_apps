import 'package:json_annotation/json_annotation.dart';
import 'permission.dart';

part 'role.g.dart';

@JsonSerializable()
class Role {
  final int id;
  final String title;
  final List<Permission>? permissions;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  Role({
    required this.id,
    required this.title,
    this.permissions,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);

  /// Check if this role has a specific permission
  bool hasPermission(String permissionTitle) {
    if (permissions == null) return false;
    return permissions!.any((p) => p.title == permissionTitle);
  }

  /// Get all permission titles for this role
  List<String> getPermissionTitles() {
    if (permissions == null) return [];
    return permissions!.map((p) => p.title).toList();
  }

  @override
  String toString() => 'Role(id: $id, title: $title, permissions: ${permissions?.length ?? 0})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
