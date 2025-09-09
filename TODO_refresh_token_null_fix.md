# TODO: Fix Null Refresh Token Issue in AuthService.login()

## Information Gathered
- AuthService.login() successfully authenticates user ("Connexion réussie")
- API response contains null/empty refresh token
- Current code saves empty refresh token and requires manual refresh
- UserService.setCurrentUser() called with empty refresh token string
- This causes poor UX as tokens expire and need manual intervention

## Root Cause
The API is not providing refresh tokens in the login response, causing the app to save empty refresh tokens and require manual refresh operations later.

## Plan
- Generate temporary refresh token when API doesn't provide one
- Update AuthService.login() to handle temporary tokens
- Modify UserService to recognize and handle temporary refresh tokens
- Ensure smooth automatic token refresh flow
- Add fallback mechanisms for refresh token generation

## Dependent Files to Edit
- lib/core/features/Agrobloc/data/dataSources/authService.dart
- lib/core/features/Agrobloc/data/dataSources/userService.dart

## Followup Steps
- [x] Generate temporary refresh token in AuthService.login()
- [x] Update UserService to handle temporary tokens
- [x] Update AuthService.refreshToken to handle temporary tokens
- [ ] Test login flow with null refresh token
- [ ] Verify automatic token refresh works
- [ ] Monitor logs for improved token handling
