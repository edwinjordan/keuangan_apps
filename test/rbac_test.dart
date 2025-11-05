import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_apps/models/role.dart';
import 'package:keuangan_apps/models/permission.dart';

void main() {
  group('RBAC Models Test', () {
    test('Role model should parse JSON correctly', () {
      // Sample JSON from API response
      final json = {
        "id": 1,
        "title": "Admin",
        "created_at": null,
        "updated_at": null,
        "deleted_at": null,
        "permissions": [
          {
            "id": 1,
            "title": "home_view",
            "created_at": null,
            "updated_at": null,
            "deleted_at": null,
            "pivot": {
              "role_id": 1,
              "permission_id": 1
            }
          },
          {
            "id": 2,
            "title": "cards_view",
            "created_at": null,
            "updated_at": null,
            "deleted_at": null,
            "pivot": {
              "role_id": 1,
              "permission_id": 2
            }
          }
        ]
      };

      // Parse JSON
      final role = Role.fromJson(json);

      // Verify role properties
      expect(role.id, equals(1));
      expect(role.title, equals('Admin'));
      expect(role.permissions, isNotNull);
      expect(role.permissions!.length, equals(2));
    });

    test('Role should correctly check permissions', () {
      final role = Role(
        id: 1,
        title: 'Admin',
        permissions: [
          Permission(id: 1, title: 'home_view'),
          Permission(id: 2, title: 'cards_view'),
          Permission(id: 3, title: 'cards_edit'),
        ],
      );

      // Test hasPermission
      expect(role.hasPermission('cards_view'), isTrue);
      expect(role.hasPermission('cards_edit'), isTrue);
      expect(role.hasPermission('non_existent'), isFalse);
    });

    test('Role should get permission titles', () {
      final role = Role(
        id: 1,
        title: 'Admin',
        permissions: [
          Permission(id: 1, title: 'home_view'),
          Permission(id: 2, title: 'cards_view'),
          Permission(id: 3, title: 'cards_edit'),
        ],
      );

      final titles = role.getPermissionTitles();
      
      expect(titles.length, equals(3));
      expect(titles, contains('home_view'));
      expect(titles, contains('cards_view'));
      expect(titles, contains('cards_edit'));
    });

    test('Permission model should parse JSON correctly', () {
      final json = {
        "id": 1,
        "title": "cards_edit",
        "created_at": null,
        "updated_at": null,
        "deleted_at": null,
        "pivot": {
          "role_id": 1,
          "permission_id": 1
        }
      };

      final permission = Permission.fromJson(json);

      expect(permission.id, equals(1));
      expect(permission.title, equals('cards_edit'));
      expect(permission.createdAt, isNull);
    });

    test('Role with null timestamps should parse correctly', () {
      final json = {
        "id": 1,
        "title": "Admin",
        "created_at": null,
        "updated_at": null,
        "deleted_at": null,
        "permissions": []
      };

      final role = Role.fromJson(json);

      expect(role.createdAt, isNull);
      expect(role.updatedAt, isNull);
      expect(role.deletedAt, isNull);
    });

    test('Role should convert to JSON correctly', () {
      final role = Role(
        id: 1,
        title: 'Admin',
        permissions: [
          Permission(id: 1, title: 'home_view'),
        ],
      );

      final json = role.toJson();

      expect(json['id'], equals(1));
      expect(json['title'], equals('Admin'));
      expect(json['permissions'], isNotNull);
    });

    test('Role equality should work correctly', () {
      final role1 = Role(id: 1, title: 'Admin');
      final role2 = Role(id: 1, title: 'Admin');
      final role3 = Role(id: 2, title: 'User');

      expect(role1, equals(role2));
      expect(role1, isNot(equals(role3)));
    });

    test('Permission equality should work correctly', () {
      final perm1 = Permission(id: 1, title: 'cards_view');
      final perm2 = Permission(id: 1, title: 'cards_view');
      final perm3 = Permission(id: 2, title: 'cards_edit');

      expect(perm1, equals(perm2));
      expect(perm1, isNot(equals(perm3)));
    });

    test('Role should handle empty permissions list', () {
      final role = Role(
        id: 1,
        title: 'User',
        permissions: [],
      );

      expect(role.hasPermission('any_permission'), isFalse);
      expect(role.getPermissionTitles(), isEmpty);
    });

    test('Role should handle null permissions list', () {
      final role = Role(
        id: 1,
        title: 'User',
        permissions: null,
      );

      expect(role.hasPermission('any_permission'), isFalse);
      expect(role.getPermissionTitles(), isEmpty);
    });
  });

  group('API Response Simulation', () {
    test('Should parse complete API response', () {
      // Complete API response from http://127.0.0.1:8000/api/v1/roles/1
      final apiResponse = {
        "success": true,
        "data": {
          "id": 1,
          "title": "Admin",
          "created_at": null,
          "updated_at": null,
          "deleted_at": null,
          "permissions": [
            {
              "id": 1,
              "title": "home_view",
              "created_at": null,
              "updated_at": null,
              "deleted_at": null,
              "pivot": {
                "role_id": 1,
                "permission_id": 1
              }
            },
            {
              "id": 2,
              "title": "cards_view",
              "created_at": null,
              "updated_at": null,
              "deleted_at": null,
              "pivot": {
                "role_id": 1,
                "permission_id": 2
              }
            },
            {
              "id": 3,
              "title": "cards_edit",
              "created_at": null,
              "updated_at": null,
              "deleted_at": null,
              "pivot": {
                "role_id": 1,
                "permission_id": 3
              }
            },
            {
              "id": 4,
              "title": "cards_show",
              "created_at": null,
              "updated_at": null,
              "deleted_at": null,
              "pivot": {
                "role_id": 1,
                "permission_id": 4
              }
            }
          ]
        },
        "message": "Role retrieved successfully."
      };

      // Parse the data portion
      final roleData = apiResponse['data'] as Map<String, dynamic>;
      final role = Role.fromJson(roleData);

      // Verify parsing
      expect(role.id, equals(1));
      expect(role.title, equals('Admin'));
      expect(role.permissions, isNotNull);
      expect(role.permissions!.length, equals(4));

      // Verify permissions
      expect(role.hasPermission('home_view'), isTrue);
      expect(role.hasPermission('cards_view'), isTrue);
      expect(role.hasPermission('cards_edit'), isTrue);
      expect(role.hasPermission('cards_show'), isTrue);

      // Verify permission titles
      final titles = role.getPermissionTitles();
      expect(titles, contains('home_view'));
      expect(titles, contains('cards_view'));
      expect(titles, contains('cards_edit'));
      expect(titles, contains('cards_show'));
    });
  });
}
