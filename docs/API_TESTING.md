# API Testing dengan Postman/Thunder Client

## Setup

### Base URL
```
http://localhost:8000/api/v1
```

---

## 1. Authentication

### Login
**POST** `/auth/login`

**Headers:**
```
Content-Type: application/json
Accept: application/json
```

**Body:**
```json
{
  "email": "admin@example.com",
  "password": "password"
}
```

**Response Success (200):**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@example.com",
    "email_verified_at": "2025-11-01T10:00:00.000000Z",
    "approved": true,
    "roles": [
      {
        "id": 1,
        "title": "Admin",
        "permissions": [
          {
            "id": 1,
            "title": "user_access"
          },
          {
            "id": 2,
            "title": "user_create"
          },
          {
            "id": 3,
            "title": "user_edit"
          }
        ]
      }
    ],
    "created_at": "2025-11-01T10:00:00.000000Z",
    "updated_at": "2025-11-01T10:00:00.000000Z"
  }
}
```

**Response Error (401):**
```json
{
  "message": "Invalid credentials"
}
```

---

### Get Current User
**GET** `/auth/me`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Response Success (200):**
```json
{
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@example.com",
    "approved": true,
    "roles": [...],
    "created_at": "2025-11-01T10:00:00.000000Z",
    "updated_at": "2025-11-01T10:00:00.000000Z"
  }
}
```

---

### Logout
**POST** `/auth/logout`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Response Success (200):**
```json
{
  "message": "Successfully logged out"
}
```

---

## 2. Users Management

### Get All Users
**GET** `/users`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Query Parameters:**
```
?page=1
&per_page=10
&search=john
```

**Response Success (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "approved": true,
      "roles": [...]
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total": 50
  }
}
```

---

### Get User by ID
**GET** `/users/{id}`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

---

### Create User
**POST** `/users`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

**Body:**
```json
{
  "name": "New User",
  "email": "newuser@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "approved": true,
  "roles": [1, 2]
}
```

---

### Update User
**PUT** `/users/{id}`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

**Body:**
```json
{
  "name": "Updated Name",
  "email": "updated@example.com",
  "approved": true,
  "roles": [1, 2, 3]
}
```

---

### Delete User
**DELETE** `/users/{id}`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

---

## 3. Roles Management

### Get All Roles
**GET** `/roles`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Response:**
```json
{
  "data": [
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
```

---

### Create Role
**POST** `/roles`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "title": "Manager",
  "permissions": [1, 2, 3]
}
```

---

## 4. Permissions Management

### Get All Permissions
**GET** `/permissions`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "user_access"
    },
    {
      "id": 2,
      "title": "user_create"
    }
  ]
}
```

---

## Common HTTP Status Codes

- **200** - OK (Success)
- **201** - Created (Resource created successfully)
- **400** - Bad Request (Invalid data)
- **401** - Unauthorized (Invalid or missing token)
- **403** - Forbidden (No permission)
- **404** - Not Found (Resource not found)
- **422** - Unprocessable Entity (Validation error)
- **500** - Internal Server Error

---

## Example Error Response

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": [
      "The email field is required."
    ],
    "password": [
      "The password must be at least 6 characters."
    ]
  }
}
```

---

## Testing Flow

1. **Login** → Get token
2. **Get Current User** → Verify authentication
3. **Get Users** → Test list endpoint
4. **Create User** → Test create with permissions
5. **Update User** → Test update
6. **Delete User** → Test delete
7. **Logout** → Invalidate token

---

## Notes

- Semua endpoint kecuali `/auth/login` memerlukan token Bearer
- Token dikirim di header: `Authorization: Bearer {your_token}`
- Content-Type harus `application/json` untuk request dengan body
- Response format mengikuti JSON API standard
