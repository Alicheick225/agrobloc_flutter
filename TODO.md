# TODO: Fix AuthenticationException in Flutter App

## Overview
The app is experiencing repeated "Utilisateur non connecté" (User not logged in) AuthenticationException errors when ApiClient attempts to make HTTP requests. This occurs because the UserService.isLoggedIn property returns false, causing ApiClient to throw an exception instead of proceeding with the request.

## Steps to Complete

### 1. Investigate API Call Sources
- [ ] Identify all locations in the codebase where ApiClient methods (get, post, put, delete) are called
- [ ] Check if these calls are properly guarded by authentication checks
- [ ] Review service classes (e.g., annonceVenteService.dart, commandeService.dart) for unguarded API calls

### 2. Analyze UserService Token Management
- [ ] Review UserService.isLoggedIn getter logic and ensure it correctly reflects authentication state
- [ ] Verify token loading and refresh mechanisms in getValidToken() method
- [ ] Check SharedPreferences key consistency and data persistence

### 3. Examine App Initialization
- [ ] Review main.dart UserService initialization and loadUser() call
- [ ] Ensure forced re-login callback is properly configured and triggered
- [ ] Verify authentication state checking in MyApp._getAuthenticationStatus()

### 4. Implement Fixes
- [ ] Add authentication guards in service classes before making API calls
- [ ] Improve error handling in ApiClient to gracefully handle unauthenticated requests
- [ ] Add logging to track when and why authentication fails

### 5. Test and Validate
- [ ] Test app behavior when user is not logged in
- [ ] Verify token refresh and session management work correctly
- [ ] Ensure no unauthorized API calls are made when unauthenticated

## Files to Modify
- lib/core/utils/api_token.dart (ApiClient class)
- lib/core/features/Agrobloc/data/dataSources/userService.dart (UserService class)
- lib/main.dart (app initialization)
- Various service classes (annonceVenteService.dart, commandeService.dart, etc.)

## Expected Outcome
- Eliminate AuthenticationException errors when user is not logged in
- Ensure API calls are only made when user is authenticated
- Improve user experience with proper authentication flow
