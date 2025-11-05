# 🧪 Testing Checklist

## Pre-Testing Setup

### ✅ 1. Backend API Ready
- [ ] Backend API sudah running
- [ ] Database sudah di-migrate
- [ ] Seeder untuk user, role, dan permission sudah dijalankan
- [ ] Endpoint `/api/v1/auth/login` berfungsi

### ✅ 2. Flutter App Configuration
- [ ] Dependencies sudah di-install (`flutter pub get`)
- [ ] Code generation sudah dijalankan (`build_runner`)
- [ ] Base URL di `constants.dart` sudah sesuai
- [ ] App berhasil di-build tanpa error

---

## 📝 Test Scenarios

### Scenario 1: Login Flow

#### Test Case 1.1: Login dengan kredensial valid
**Steps:**
1. Buka aplikasi
2. Input email: `admin@example.com`
3. Input password: `password`
4. Klik tombol Login

**Expected Result:**
- ✅ Loading indicator muncul
- ✅ Redirect ke Home Screen
- ✅ User info ditampilkan dengan benar
- ✅ Roles dan permissions ditampilkan

**Status:** [ ] Pass [ ] Fail

---

#### Test Case 1.2: Login dengan email invalid
**Steps:**
1. Input email: `invalidemail`
2. Input password: `password`
3. Klik tombol Login

**Expected Result:**
- ✅ Error validation "Email tidak valid" muncul
- ✅ Tidak ada API call

**Status:** [ ] Pass [ ] Fail

---

#### Test Case 1.3: Login dengan password salah
**Steps:**
1. Input email: `admin@example.com`
2. Input password: `wrongpassword`
3. Klik tombol Login

**Expected Result:**
- ✅ Error message dari backend ditampilkan
- ✅ Tetap di Login Screen

**Status:** [ ] Pass [ ] Fail

---

#### Test Case 1.4: Login dengan field kosong
**Steps:**
1. Biarkan email dan password kosong
2. Klik tombol Login

**Expected Result:**
- ✅ Validation error muncul pada kedua field
- ✅ Tidak ada API call

**Status:** [ ] Pass [ ] Fail

---

### Scenario 2: Auto-Login

#### Test Case 2.1: Auto-login untuk user yang sudah login
**Steps:**
1. Login dengan kredensial valid
2. Close app (tidak logout)
3. Buka app lagi

**Expected Result:**
- ✅ Splash screen muncul sebentar
- ✅ Auto redirect ke Home Screen
- ✅ User data masih tersimpan

**Status:** [ ] Pass [ ] Fail

---

### Scenario 3: RBAC - Role Based Access

#### Test Case 3.1: Admin Role Features
**Steps:**
1. Login sebagai user dengan role "Admin"
2. Lihat Home Screen

**Expected Result:**
- ✅ "Admin Dashboard" card terlihat (purple background)
- ✅ Role "Admin" muncul di chips
- ✅ Semua permissions Admin terlihat

**Status:** [ ] Pass [ ] Fail

---

#### Test Case 3.2: Non-Admin Role Features
**Steps:**
1. Login sebagai user tanpa role "Admin"
2. Lihat Home Screen

**Expected Result:**
- ✅ "Admin Dashboard" card TIDAK terlihat
- ✅ Only public features terlihat

**Status:** [ ] Pass [ ] Fail

---

### Scenario 4: RBAC - Permission Based Access

#### Test Case 4.1: User dengan permission 'user_access'
**Steps:**
1. Login sebagai user dengan permission 'user_access'
2. Scroll ke Feature Access Demo section

**Expected Result:**
- ✅ "User Management" card terlihat (blue background)
- ✅ Permission 'user_access' muncul di chips

**Status:** [ ] Pass [ ] Fail

---

#### Test Case 4.2: User tanpa required permissions
**Steps:**
1. Login sebagai user tanpa permission 'ticket_create' dan 'ticket_edit'
2. Scroll ke Feature Access Demo

**Expected Result:**
- ✅ "Ticket Editor" card TIDAK terlihat
- ✅ Public feature tetap terlihat

**Status:** [ ] Pass [ ] Fail

---

### Scenario 5: Logout

#### Test Case 5.1: Normal logout
**Steps:**
1. Login dengan kredensial valid
2. Klik icon logout di AppBar
3. Konfirmasi logout

**Expected Result:**
- ✅ Confirmation dialog muncul
- ✅ Setelah konfirmasi, redirect ke Login Screen
- ✅ Token dihapus dari storage
- ✅ User data dihapus

**Status:** [ ] Pass [ ] Fail

---

#### Test Case 5.2: Cancel logout
**Steps:**
1. Klik icon logout
2. Klik "Batal" pada dialog

**Expected Result:**
- ✅ Dialog tertutup
- ✅ Tetap di Home Screen
- ✅ User masih logged in

**Status:** [ ] Pass [ ] Fail

---

### Scenario 6: Refresh User Data

#### Test Case 6.1: Refresh user info
**Steps:**
1. Login dengan kredensial valid
2. Klik icon refresh di AppBar

**Expected Result:**
- ✅ Loading state (optional)
- ✅ User data di-refresh dari server
- ✅ Roles dan permissions ter-update

**Status:** [ ] Pass [ ] Fail

---

### Scenario 7: User Status Display

#### Test Case 7.1: User approved & email verified
**Steps:**
1. Login sebagai user dengan:
   - approved: true
   - email_verified_at: not null

**Expected Result:**
- ✅ Chip "Approved" dengan background hijau
- ✅ Chip "Email Verified" dengan background biru

**Status:** [ ] Pass [ ] Fail

---

#### Test Case 7.2: User not approved
**Steps:**
1. Login sebagai user dengan approved: false

**Expected Result:**
- ✅ Chip "Not Approved" dengan background merah
- ✅ Icon cancel pada chip

**Status:** [ ] Pass [ ] Fail

---

### Scenario 8: Network Error Handling

#### Test Case 8.1: Login tanpa koneksi internet
**Steps:**
1. Matikan internet/wifi
2. Coba login

**Expected Result:**
- ✅ Error message "Network error" atau similar
- ✅ Tetap di Login Screen

**Status:** [ ] Pass [ ] Fail

---

#### Test Case 8.2: Backend tidak running
**Steps:**
1. Stop backend server
2. Coba login

**Expected Result:**
- ✅ Error message ditampilkan
- ✅ Tidak crash

**Status:** [ ] Pass [ ] Fail

---

## 🎨 UI/UX Testing

### Visual Checks
- [ ] Logo/icon terlihat dengan jelas
- [ ] Warna konsisten dengan theme
- [ ] Text readable dan tidak terpotong
- [ ] Button states (normal, pressed, disabled) terlihat baik
- [ ] Loading indicator terlihat saat proses
- [ ] Error messages terlihat jelas

### Responsive Design
- [ ] UI terlihat baik di berbagai ukuran screen
- [ ] Scrolling lancar
- [ ] Keyboard tidak menutupi input field
- [ ] Safe area respected (notch, status bar)

---

## 🔒 Security Testing

### Token Management
- [ ] Token disimpan di secure storage
- [ ] Token auto-inject ke API requests
- [ ] Token dihapus saat logout
- [ ] Expired token handling (jika implemented)

### Data Persistence
- [ ] User data tersimpan dengan aman
- [ ] Sensitive data tidak di-log
- [ ] Password tidak pernah disimpan

---

## 📱 Device Testing

### Android
- [ ] Android Emulator
- [ ] Physical Android device
- [ ] Berbagai versi OS (min SDK)

### iOS (jika applicable)
- [ ] iOS Simulator
- [ ] Physical iOS device
- [ ] Berbagai versi iOS

---

## 🐛 Bug Tracking Template

**Bug #:** ___  
**Test Case:** ___  
**Severity:** [ ] Critical [ ] High [ ] Medium [ ] Low  
**Description:**  


**Steps to Reproduce:**  
1. 
2. 
3. 

**Expected Result:**  


**Actual Result:**  


**Screenshots/Logs:**  


**Environment:**  
- Device: ___
- OS: ___
- App Version: ___

---

## ✅ Test Summary

**Total Test Cases:** 21  
**Passed:** ___  
**Failed:** ___  
**Skipped:** ___  

**Pass Rate:** ___%

**Tested By:** _______________  
**Test Date:** _______________  
**Notes:**  


---

## 📝 Sign-off

**Developer:** _______________ Date: _______  
**Tester:** _______________ Date: _______  
**Approved:** _______________ Date: _______
