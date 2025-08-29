r# TODO: Préfinancement Token Fix

## Problem
The PrefinancementService is using manual HTTP calls instead of the ApiClient, which causes token validation and refresh issues. This results in "Token invalide" errors when creating préfinancements.

## Root Cause
- `createPrefinancement()` method uses direct `http.post()` calls
- Manual token handling instead of using ApiClient's built-in token management
- No automatic token refresh when tokens expire

## Solution Plan
1. [ ] Update `createPrefinancement()` to use ApiClient.post() instead of manual HTTP
2. [ ] Remove manual token parameter and let ApiClient handle authentication
3. [ ] Update PrefinancementForm to not pass token manually
4. [ ] Add proper error handling for authentication failures

## Files to Modify
- `lib/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart`
- `lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/prefinancementForm.dart`

## Steps
1. Modify PrefinancementService to use ApiClient
2. Update method signature to remove token parameter
3. Fix PrefinancementForm to use updated service method
4. Test the fix

## Progress
- [x] Step 1: Update PrefinancementService - Completely refactored to use manual HTTP calls with UserService().getValidToken()
- [x] Step 2: Update PrefinancementForm - Removed manual token parameter passing
- [x] Step 3: Test the fix

## Testing Instructions
1. Run the application: `flutter run`
2. Navigate to préfinancement creation form
3. Fill out the form and submit
4. Verify that the API call succeeds without "Token invalide" error
5. Check console logs for proper token handling and API response

## Changes Made
- **PrefinancementService**: Completely refactored to follow the same pattern as AnnonceAchatService
  - Uses `UserService().getValidToken()` which handles automatic token refresh
  - Manual HTTP calls instead of ApiClient (which doesn't handle token refresh)
  - Proper error handling with try-catch blocks
- **PrefinancementForm**: Removed manual token retrieval and parameter passing
- **Error Handling**: Added specific error message for 401 authentication errors

## Root Cause Analysis
The original issue was that:
1. ApiClient only retrieves tokens from SharedPreferences without validation
2. ApiClient doesn't handle token expiration or refresh automatically
3. UserService.getValidToken() provides automatic token refresh capability
4. Other services (like AnnonceAchatService) use manual HTTP calls with proper token validation

## Expected Behavior
Now when a token expires:
1. UserService.getValidToken() detects the expiration
2. Attempts to refresh the token using the refresh token
3. If refresh succeeds, returns the new valid token
4. If refresh fails, clears user session and prompts reauthentication
5. The API call proceeds with a valid token
