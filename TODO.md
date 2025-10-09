# TODO: Fix "User not logged in" Exception in Real-time Annonce Verification

## Issue Description
The Flutter app throws "Exception: User not logged in" when attempting real-time verification of announcements before placing orders. This occurs in `offreDetail.dart` when calling `AnnonceService.getAnnonceByID()`.

## Root Cause Analysis
- `AnnonceService` methods check `UserService().isLoggedIn` before API calls
- `UserService.isLoggedIn` returns `false` when `_currentUser == null || _token == null || _token!.isEmpty`
- User session may not be properly persisted or loaded after login/app restart
- `UserService.storeUser()` method is empty and doesn't save user data
- Token refresh mechanism may fail, causing session invalidation

## Tasks to Complete

### 1. Analyze Current UserService.storeUser Implementation
- [x] Review the empty `storeUser` method in `userService.dart`
- [x] Understand why login flow doesn't properly save user session
- [x] Check if `AuthService.login()` properly calls `UserService.setCurrentUser()`
- [x] Implement proper user and token storage in storeUser method

### 2. Implement Proper User and Token Storage in storeUser
- [ ] Implement `UserService.storeUser()` to call `setCurrentUser()` with user and tokens
- [ ] Ensure tokens are retrieved from AuthService or UserService instance
- [ ] Add proper error handling and validation

### 3. Verify Login Flow and Session Persistence
- [ ] Test that login properly saves user data to SharedPreferences
- [ ] Verify `UserService.loadUser()` loads data correctly on app start
- [ ] Check token refresh mechanism works properly

### 4. Improve Authentication State Management
- [x] Add better error handling in `AnnonceService` methods
- [x] Implement user-friendly feedback when authentication fails
- [x] Add session recovery mechanisms for expired tokens
- [x] Improve error messages in offreDetail.dart and commandesProduit.dart
- [x] Add login redirect action in error snackbars

### 5. Test and Validate Fixes
- [ ] Test login flow saves user session correctly
- [ ] Test app restart maintains user session
- [ ] Test real-time annonce verification works when logged in
- [ ] Test error handling when not logged in

## Files to Modify
- `lib/core/features/Agrobloc/data/dataSources/userService.dart` - Implement storeUser method
- `lib/core/features/Agrobloc/presentations/widgets/connexion/login.dart` - Ensure proper user storage after login
- `lib/core/features/Agrobloc/presentations/widgets/acheteurs/home/offreDetail.dart` - Improve error handling and user feedback

## Expected Outcome
- Users remain logged in across app sessions
- Real-time annonce verification works for authenticated users
- Clear error messages when authentication is required
- Proper session management and token refresh

## Summary of Changes Made

### ✅ Completed Tasks
1. **UserService.storeUser() Implementation**: Added proper user and token storage method that calls setCurrentUser() with validation and error handling.

2. **Improved Error Handling in offreDetail.dart**: 
   - Added user-friendly error messages for authentication failures
   - Added "Se connecter" action button in snackbar to redirect to login
   - Better error categorization (auth vs other errors)

3. **Improved Error Handling in commandesProduit.dart**:
   - Similar improvements as offreDetail.dart
   - Proper handling of authentication errors with login redirect
   - Maintained existing logic for annonce availability checks

### 🔄 Remaining Tasks (Require Testing)
- Test login flow saves user session correctly
- Test app restart maintains user session
- Test real-time annonce verification works when logged in
- Test error handling when not logged in
- Verify token refresh mechanism works properly

### 📋 Files Modified
- `lib/core/features/Agrobloc/data/dataSources/userService.dart` - Implemented storeUser method
- `lib/core/features/Agrobloc/presentations/widgets/acheteurs/home/offreDetail.dart` - Improved error handling
- `lib/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/commandesProduit.dart` - Improved error handling
