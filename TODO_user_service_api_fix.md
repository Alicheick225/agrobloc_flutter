# UserService API Access Denied Fix - TODO List

## Files to Modify:
- [ ] `lib/core/features/Agrobloc/data/dataSources/authService.dart`
- [ ] `lib/core/features/Agrobloc/data/dataSources/userService.dart`
- [ ] `lib/core/utils/api_token.dart` (optional improvements)

## Changes Needed:

### AuthService.dart
1. [ ] Modify `getUserById()` to parse response body for error messages
2. [ ] Add proper error type detection (access denied vs other errors)
3. [ ] Improve error messages to be more specific
4. [ ] Add response body parsing for error detection

### UserService.dart
1. [ ] Enhance `loadUser()` to handle different error types
2. [ ] Add token validation before API calls
3. [ ] Improve error logging for better debugging
4. [ ] Add retry logic for token-related errors

### ApiToken.dart (Optional)
1. [ ] Add token expiration checking
2. [ ] Add automatic token refresh capability

## Testing Scenarios:
- [ ] Test with valid token and user data
- [ ] Test with expired/invalid token (access denied)
- [ ] Test with network errors
- [ ] Test with missing user data
- [ ] Verify proper error messages and session cleanup

## Current Issue:
API returns HTTP 200 with error message "Accès refusé" in response body, but current code only checks status code.
