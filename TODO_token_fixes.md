# TODO: Token Management Fixes

## Issues Identified
- [x] Temporary refresh tokens not API-compatible
- [x] Token expiration causing repeated failures
- [x] Duplicate token validation in services
- [x] Poor error handling for authentication failures

## Fixes to Implement

### 1. Fix Temporary Refresh Token Handling
- [x] Remove automatic generation of temporary refresh tokens
- [x] Handle missing refresh tokens from API more gracefully
- [x] Add proper fallback when refresh tokens are unavailable

### 2. Improve Token Refresh Strategy
- [x] Don't clear tokens immediately on refresh failure
- [x] Implement better detection of permanent vs temporary failures
- [ ] Add re-authentication prompts when needed

### 3. Unify Token Management
- [x] Update AnnonceService to use UserService.getValidToken()
- [x] Remove duplicate JWT validation logic
- [x] Centralize token expiration handling

### 4. Enhance Error Handling
- [x] Add specific error types for authentication issues
- [x] Improve user feedback for token-related errors
- [ ] Add retry logic for network-related failures

### 5. Testing and Validation
- [ ] Test token refresh scenarios
- [ ] Verify backup token recovery works
- [ ] Test circuit breaker behavior with token issues

## Summary of Fixes Implemented

### ✅ Completed Fixes:
1. **Removed Temporary Refresh Token Generation**: Eliminated the problematic generation of temporary refresh tokens that weren't API-compatible
2. **Improved Missing Refresh Token Handling**: When API doesn't provide refresh tokens, the app now saves without them and handles the scenario gracefully
3. **Better Token Refresh Strategy**: Modified UserService to not immediately clear tokens when refresh fails due to missing refresh tokens
4. **Unified Token Management**: Updated AnnonceService to use UserService's centralized token management instead of its own JWT validation
5. **Enhanced Error Handling**: Added specific exception classes (AuthenticationException, TokenExpiredException, etc.) for better error categorization

### 🔧 Key Changes Made:
- **AuthService**: Removed temporary refresh token generation in login() and register() methods
- **UserService**: Improved handling of missing refresh tokens, removed temporary token logic
- **AnnonceService**: Now uses UserService.getValidToken() for centralized token management
- **ApiClient**: Added specific authentication exception classes for better error handling

### 🎯 Expected Results:
- No more infinite loops between expired tokens and failed refresh attempts
- More stable authentication flow
- Better error messages for users
- Centralized token management across all services
- Graceful handling when refresh tokens are unavailable
