# TODO: Token Refresh Callback Fix

## Problem Analysis
- Refresh token stored as empty string instead of null
- Force re-login callback never set in main.dart
- App fails silently when tokens expire with "Aucun callback de reconnexion défini"
- No navigation to login page when session expires

## Solution Plan

### 1. Fix Empty Refresh Token Handling in UserService
- [x] Modify `getValidToken()` to properly handle empty refresh tokens
- [x] Treat empty strings as null for refresh token validation
- [x] Improve logging for empty refresh token cases

### 2. Set Force Re-login Callback in main.dart
- [x] Add callback to UserService in main() function
- [x] Implement navigation to login page when session expires
- [x] Add proper error handling and user feedback

### 3. Improve Token Refresh Logic
- [x] Better error handling for empty refresh tokens
- [x] Prevent infinite loops in refresh attempts
- [x] Add fallback mechanisms for token recovery

### 4. Add Session Expiry Navigation
- [x] Implement proper routing to login when tokens are invalid
- [x] Clear navigation stack to prevent back navigation
- [x] Show user-friendly messages for session expiry

## Files to Modify
- `lib/core/features/Agrobloc/data/dataSources/userService.dart`
- `lib/main.dart`

## Expected Outcome
- Proper handling of empty refresh tokens
- Automatic navigation to login when session expires
- Clear user feedback during authentication issues
- No more silent failures in token refresh
