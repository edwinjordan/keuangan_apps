# Dokumentasi Role, User, dan Permission

## Daftar Isi
1. [Gambaran Umum](#gambaran-umum)
2. [Struktur Database](#struktur-database)
3. [Model dan Relasi](#model-dan-relasi)
4. [Implementasi](#implementasi)
5. [API Endpoints](#api-endpoints)
6. [Contoh Penggunaan](#contoh-penggunaan)

---

## Gambaran Umum

Sistem Resolvy menggunakan pola **Role-Based Access Control (RBAC)** untuk mengelola hak akses pengguna. Sistem ini terdiri dari tiga komponen utama:

- **User (Pengguna)**: Akun pengguna dalam sistem
- **Role (Peran)**: Grup yang mendefinisikan tingkat akses pengguna
- **Permission (Izin)**: Hak akses spesifik untuk melakukan tindakan tertentu

### Hubungan Antar Komponen

```
User ←→ Role ←→ Permission
```

- Satu User dapat memiliki **banyak Role** (Many-to-Many)
- Satu Role dapat memiliki **banyak Permission** (Many-to-Many)
- User mendapatkan Permission melalui Role yang dimilikinya

---

## Struktur Database

### Tabel: `users`

Menyimpan informasi pengguna sistem.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | BIGINT (PK) | ID unik pengguna |
| `name` | VARCHAR | Nama lengkap pengguna |
| `email` | VARCHAR (UNIQUE) | Alamat email (untuk login) |
| `email_verified_at` | DATETIME | Waktu verifikasi email |
| `password` | VARCHAR | Password terenkripsi |
| `approved` | BOOLEAN | Status persetujuan admin (default: false) |
| `remember_token` | VARCHAR | Token untuk "remember me" |
| `created_at` | TIMESTAMP | Waktu dibuat |
| `updated_at` | TIMESTAMP | Waktu diperbarui |
| `deleted_at` | TIMESTAMP | Waktu dihapus (soft delete) |
### Tabel: `roles`

Menyimpan peran/role dalam sistem.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | BIGINT (PK) | ID unik role |
| `title` | VARCHAR | Nama role (contoh: Admin, User, Support) |
| `created_at` | TIMESTAMP | Waktu dibuat |
| `updated_at` | TIMESTAMP | Waktu diperbarui |
| `deleted_at` | TIMESTAMP | Waktu dihapus (soft delete) |
### Tabel: `permissions`

Menyimpan izin akses dalam sistem.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | BIGINT (PK) | ID unik permission |
| `title` | VARCHAR | Nama permission (contoh: user_access, ticket_create) |
| `created_at` | TIMESTAMP | Waktu dibuat |
| `updated_at` | TIMESTAMP | Waktu diperbarui |
| `deleted_at` | TIMESTAMP | Waktu dihapus (soft delete) |

### Tabel Pivot: `role_user`

Menghubungkan User dengan Role (Many-to-Many).

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `user_id` | BIGINT (FK) | ID pengguna |
| `role_id` | BIGINT (FK) | ID role |

**Foreign Keys**:
- `user_id` → `users.id` (ON DELETE CASCADE)
- `role_id` → `roles.id` (ON DELETE CASCADE)

### Tabel Pivot: `permission_role`

Menghubungkan Permission dengan Role (Many-to-Many).

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `permission_id` | BIGINT (FK) | ID permission |
| `role_id` | BIGINT (FK) | ID role |

**Foreign Keys**:
- `permission_id` → `permissions.id` (ON DELETE CASCADE)
- `role_id` → `roles.id` (ON DELETE CASCADE)

#### Relasi

```php
// User belongsToMany Role
public function roles()
{
    return $this->belongsToMany(Role::class);
}
```

#### Accessor & Mutator


---

## Implementasi

---

## API Endpoints

### Permissions API

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/permissions` | Mendapatkan daftar semua permissions |
| POST | `/api/v1/permissions` | Membuat permission baru |
| GET | `/api/v1/permissions/{id}` | Mendapatkan detail permission |
| PUT/PATCH | `/api/v1/permissions/{id}` | Mengupdate permission |
| DELETE | `/api/v1/permissions/{id}` | Menghapus permission |

### Roles API

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/roles` | Mendapatkan daftar semua roles |
| POST | `/api/v1/roles` | Membuat role baru |
| GET | `/api/v1/roles/{id}` | Mendapatkan detail role |
| PUT/PATCH | `/api/v1/roles/{id}` | Mengupdate role |
| DELETE | `/api/v1/roles/{id}` | Menghapus role |

### Users API

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/users` | Mendapatkan daftar semua users |
| POST | `/api/v1/users` | Membuat user baru |
| GET | `/api/v1/users/{id}` | Mendapatkan detail user |
| PUT/PATCH | `/api/v1/users/{id}` | Mengupdate user |
| DELETE | `/api/v1/users/{id}` | Menghapus user |

---



---


### Best Practices
1. **Gunakan Repository Pattern** untuk konsistensi akses data
2. **Eager Loading** untuk menghindari N+1 query problem
3. **Validasi** input saat membuat/update user, role, atau permission
4. **Authorization** selalu cek permission sebelum aksi penting
5. **Audit Trail** pertimbangkan logging untuk perubahan role/permission

---

## Diagram Relasi

```
┌─────────────────┐
│     users       │
├─────────────────┤
│ id              │◄──────┐
│ name            │       │
│ email           │       │ Many-to-Many
│ password        │       │
│ approved        │       │
│ ...             │       │
└─────────────────┘       │
                          │
                    ┌─────┴──────┐
                    │ role_user  │
                    ├────────────┤
                    │ user_id    │
                    │ role_id    │
                    └─────┬──────┘
                          │
┌─────────────────┐       │
│     roles       │       │
├─────────────────┤       │
│ id              │◄──────┘
│ title           │◄──────┐
│ ...             │       │
└─────────────────┘       │
                          │ Many-to-Many
                          │
                    ┌─────┴────────────┐
                    │ permission_role  │
                    ├──────────────────┤
                    │ permission_id    │
                    │ role_id          │
                    └─────┬────────────┘
                          │
┌─────────────────┐       │
│  permissions    │       │
├─────────────────┤       │
│ id              │◄──────┘
│ title           │
│ ...             │
└─────────────────┘
```

---

**Dibuat**: November 2025  
**Versi**: 1.0  
**Project**: Resolvy - Ticket Management System
