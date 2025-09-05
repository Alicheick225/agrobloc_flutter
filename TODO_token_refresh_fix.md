# TODO: Token Refresh Fix Plan

## Information Gathered
- The UserService.getValidToken method attempts to refresh the access token using the refresh token.
- If the refresh token is invalid or missing, it tries to use a backup token to refresh.
- The refreshToken method in AuthService calls the API to refresh tokens and handles various error cases.
- The ApiClient class performs API calls with retry, exponential backoff, and circuit breaker.
- The error logs indicate failures in refreshing token with backup token due to server not accessible.
- Forced re-login is triggered when refresh fails and no callback is defined.
- The current implementation has detailed logging but may not handle network errors optimally during refresh.

## Plan
- Improve network error handling in UserService.getValidToken to better distinguish between server unreachable and other errors.
- Enhance retry logic or fallback mechanisms when refresh with backup token fails due to network issues.
- Consider adding a delay or retry before triggering forced re-login on network errors.
- Add more robust circuit breaker or exponential backoff in ApiClient for refresh token calls.
- Ensure forced re-login callback is always set or fallback cleanup is safe.
- Add user-friendly error messages or UI feedback for network issues during token refresh.
- Test the improved flow to reduce forced re-login occurrences due to transient network errors.

## Dependent Files to Edit
- lib/core/features/Agrobloc/data/dataSources/userService.dart
- lib/core/features/Agrobloc/data/dataSources/authService.dart
- lib/core/utils/api_token.dart

## Followup Steps
- [x] Implement retry logic with delay in UserService.getValidToken for refresh attempts
- [x] Add retry logic in AuthService.refreshToken for network errors
- [x] Enhance server reachability check in ApiClient with retry
- [x] Test code compilation and syntax validation
- [ ] Test token refresh under various network conditions (manual testing required)
- [ ] Monitor logs for reduced forced re-login triggers (runtime testing required)
- [ ] Update documentation and error handling as needed

## Completed Changes
- Enhanced UserService.getValidToken with retry logic (3 attempts, 2s delay) for refresh with backup token
- Added retry logic in AuthService.refreshToken (2 attempts, 1s delay) for network errors
- Improved ApiClient._checkServerReachability with retry (2 attempts, 1s delay, reduced timeout to 5s)
- Better error handling and logging throughout the token refresh flow
- Forced re-login callback is safely called after max retries
