# TODO: Fix Flutter App Issues

## 1. Fix Token Refresh Failure ✅
- [x] Modify AuthService.refreshToken to handle 404 errors gracefully
- [x] Add specific handling for missing refresh endpoint
- [x] Prevent repeated authentication failures

## 2. Fix RenderFlex Overflow ✅
- [x] Identify widgets causing overflow in transaction pages
- [x] Adjust padding/margins to prevent overflow
- [x] Test layout on different screen sizes
