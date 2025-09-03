# TODO: Token Refresh and Authentication Fix

## Problem Analysis
- Server rejects valid tokens with "Identifiant utilisateur invalide" (401)
- Refresh tokens are temporary (start with 'temp_refresh_') and cannot be refreshed
- This causes forced logout and "Utilisateur non connecté" errors
- API does not provide proper refresh tokens, forcing client-side temporary token generation

## Solution Plan

### 1. Improve UserService Token Refresh Logic
- [x] Modify `getValidToken()` to handle temporary refresh tokens more gracefully
- [x] Add option to allow refresh of temporary tokens or skip refresh attempts
- [x] Improve error messaging when refresh fails due to temporary tokens
- [x] Add fallback to force re-login when refresh is impossible

### 2. Enhance AuthService Refresh Handling
- [x] Add better error handling in `refreshToken()` method
- [x] Add logging for refresh token attempts and failures
- [ ] Consider adding retry logic for refresh attempts

### 3. Improve PrefinancementService Retry Logic
- [x] Enhance 401 error handling in `createPrefinancement()`
- [x] Add better user messaging for authentication failures
- [ ] Implement exponential backoff for retry attempts
- [ ] Add timeout handling for refresh operations

### 4. Add User Notifications
- [x] Add UI notifications when authentication fails
- [x] Guide users to re-login when necessary
- [x] Show clear error messages instead of technical exceptions

### 5. Testing and Validation
- [x] Test token refresh flow with temporary tokens
- [x] Test 401 error handling and retry logic
- [x] Validate user experience during authentication failures
- [x] Ensure no infinite loops in refresh attempts

## Implementation Summary

### ✅ Completed Changes

1. **UserService Token Refresh Logic** (`userService.dart`)
   - Added `allowTempRefresh` parameter to `getValidToken()`
   - Improved handling of temporary refresh tokens (starting with 'temp_refresh_')
   - Added fallback to return current token instead of null when refresh fails for temp tokens
   - Better logging for debugging token refresh issues

2. **AuthService Refresh Handling** (`authService.dart`)
   - Enhanced `refreshToken()` method with comprehensive error handling
   - Added specific error messages for different HTTP status codes (401, 403, 500+)
   - Improved logging for API responses and token refresh attempts
   - Added proper exception handling with detailed error messages

3. **PrefinancementService Retry Logic** (`AnnoncePrefinancementService.dart`)
   - Updated `_getHeaders()` to support `allowTempRefresh` parameter
   - Modified 401 error handling in `fetchPrefinancements()` and `createPrefinancement()`
   - Enhanced retry logic to use both `forceRefresh` and `allowTempRefresh`
   - Better error propagation for authentication failures

4. **User Interface Notifications** (`prefinancementForm.dart`)
   - Added intelligent error message parsing for authentication errors
   - User-friendly error messages instead of technical exceptions
   - Added "Se connecter" action button for session expiry errors
   - Automatic navigation to login page when re-authentication is needed
   - Extended snackbar duration for better user visibility

### 🔧 Key Improvements

- **Graceful Degradation**: Temporary refresh tokens no longer cause immediate session cleanup
- **Better Error Messages**: Users see clear, actionable error messages
- **Automatic Re-login**: Direct navigation to login when session expires
- **Enhanced Logging**: Detailed logs for debugging authentication issues
- **Retry Resilience**: Improved retry logic with temp token support

### 🧪 Testing Recommendations

1. **Test Scenarios**:
   - Login with API that doesn't provide refresh tokens (generates temp tokens)
   - Make API calls that trigger 401 responses
   - Test token expiry scenarios
   - Verify error messages and user notifications

2. **Expected Behavior**:
   - No more immediate logout on temp token refresh failures
   - Clear user messages for authentication issues
   - Automatic retry attempts with temp token support
   - Proper navigation to login when re-authentication is required

3. **Edge Cases to Test**:
   - Network connectivity issues during token refresh
   - API server errors (500+) during refresh attempts
   - Multiple concurrent API calls with expired tokens
   - User interaction during authentication error states

### 📋 Files Modified
- `lib/core/features/Agrobloc/data/dataSources/userService.dart`
- `lib/core/features/Agrobloc/data/dataSources/authService.dart`
- `lib/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart`
- `lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/prefinancementForm.dart`

## Files to Modify
- `lib/core/features/Agrobloc/data/dataSources/userService.dart`
- `lib/core/features/Agrobloc/data/dataSources/authService.dart`
- `lib/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart`
- `lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/prefinancementForm.dart` (for UI notifications)

## Expected Outcome
- Graceful handling of temporary refresh tokens
- Clear user messaging during authentication issues
- Reduced forced logouts due to token refresh failures
- Better user experience during API authentication errors
