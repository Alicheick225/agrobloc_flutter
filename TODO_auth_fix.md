# TODO: Fix Authentication Check in main.dart

## Current Issue
- main.dart uses `UserService.isLoggedIn` which only checks if user and token exist, but doesn't validate token expiration
- User is not redirected to login page when token is expired

## Plan
- Replace `isLoggedIn` with `isUserAuthenticated()` which checks token expiration
- Handle async nature of `isUserAuthenticated()` in build method
- Use FutureBuilder or state management to handle authentication check

## Steps
- [x] Update main.dart to use isUserAuthenticated() instead of isLoggedIn
- [x] Handle async authentication check in build method
- [x] Test app launch behavior to ensure proper redirect to login page ✅ SUCCESSFUL
- [x] Fix ParcelleService base URL to use annoncesBaseUrl (port 8080) instead of apiBaseUrl (port 3000) ✅ FIXED
