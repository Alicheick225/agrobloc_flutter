# Login Error Handling Fix

## Issue:
The login method in authService.dart only checks HTTP status code but doesn't check response body for error messages. The API might return HTTP 200 with error messages like "Accès refusé" in the response body, causing "access token manquant" error.

## Files to Modify:
- [x] `lib/core/features/Agrobloc/data/dataSources/authService.dart`

## Changes Needed:
1. [x] Add response body parsing for error detection in login method
2. [x] Check for error messages even when status code is 200
3. [x] Add specific error handling for common authentication errors
4. [x] Improve error messages for better debugging

## Expected Behavior:
- Proper detection of API errors in response body
- Clear error messages indicating the exact authentication issue
- Prevention of "access token manquant" error when API returns error messages

## Testing Scenarios:
- [ ] Test login with valid credentials
- [ ] Test login with invalid credentials
- [ ] Test login when API returns HTTP 200 with error message
- [ ] Verify proper error messages are displayed
