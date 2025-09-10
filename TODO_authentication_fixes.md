# TODO: Authentication System Fixes

## Problem Analysis

The authentication system is experiencing repeated failures due to:

1. **Server Issue**: Refresh endpoint (`/refresh`) returns 404 with HTML error page instead of JSON
2. **Poor Error Handling**: Code doesn't properly handle HTML responses from server errors
3. **Circuit Breaker Logic**: Opens but doesn't prevent all retry attempts effectively
4. **Backup Token Misuse**: Attempts to use backup tokens for refresh when endpoint doesn't exist
5. **No Endpoint Availability Detection**: No mechanism to detect unavailable endpoints

## Root Cause from Logs

```
🔍 AuthService.refreshToken() - Réponse API: Status 404
🔍 AuthService.refreshToken() - Body length: 123 chars
⚠️ AuthService.refreshToken() - JSON parsing error: FormatException: Unexpected character (at character 1)
<!DOCTYPE html>
```

The server returns HTML error pages instead of JSON, causing JSON parsing to fail.

## Comprehensive Fix Plan

### 1. Enhanced AuthService (authService_improved.dart)

**Status**: ✅ Created improved version

**Key Improvements**:
- ✅ Better HTML response detection (`_isHtmlResponse()`)
- ✅ Endpoint availability tracking (`_isRefreshEndpointUnavailable()`, `_setRefreshEndpointAvailable()`)
- ✅ Improved error handling for 404 responses
- ✅ Retry logic with proper error categorization
- ✅ Circuit breaker awareness

**New Methods Added**:
```dart
bool _isHtmlResponse(String responseBody)
Future<bool> _isRefreshEndpointUnavailable()
Future<void> _setRefreshEndpointAvailable(bool available)
```

### 2. Enhanced UserService (userService_improved.dart)

**Status**: 📝 Needs implementation

**Key Improvements Needed**:
- ✅ Circuit breaker state checking before refresh attempts
- ✅ Better handling of endpoint unavailable errors
- ✅ Improved retry logic that respects circuit breaker
- ✅ Enhanced backup token logic

**Critical Changes**:
```dart
// Check circuit breaker before refresh
final apiClient = ApiClient('${ApiConfig.apiBaseUrl}/authentification');
if (apiClient._isCircuitBreakerOpen()) {
  // Handle circuit breaker open state
}

// Better error handling for unavailable endpoints
if (error.contains('Endpoint de refresh non trouvé') ||
    error.contains('non disponible')) {
  // Continue with current token if valid
}
```

### 3. ApiClient Circuit Breaker Integration

**Status**: ✅ Already implemented in api_token.dart

**Current Features**:
- ✅ Circuit breaker pattern with timeout
- ✅ Exponential backoff for retries
- ✅ Failure count tracking
- ✅ Automatic recovery after timeout

**Integration Points**:
- Circuit breaker opens after 3 failures
- 30-second timeout before retry attempts
- Exponential backoff: 500ms → 1s → 2s → 4s → 8s → 10s (max)

### 4. Implementation Steps

#### Step 1: Replace AuthService
```dart
// In files that import authService.dart, change to:
import 'authService_improved.dart' as AuthService;
```

#### Step 2: Replace UserService
```dart
// In files that import userService.dart, change to:
import 'userService_improved.dart' as UserService;
```

#### Step 3: Update Imports in Dependent Files
- Find all files importing the old services
- Update import statements
- Test compilation

#### Step 4: Test Scenarios
- ✅ Token expiration handling
- ✅ Network errors during refresh
- ✅ Server returning HTML errors
- ✅ Circuit breaker opening/closing
- ✅ Backup token recovery

### 5. Error Handling Improvements

**Before**:
```dart
try {
  data = jsonDecode(response.body);
} catch (e) {
  // Fails on HTML responses
}
```

**After**:
```dart
if (_isHtmlResponse(response.body)) {
  errorMessage = "Réponse serveur inattendue (HTML au lieu de JSON)";
} else {
  try {
    data = jsonDecode(response.body);
  } catch (e) {
    data = _parseManualResponse(response.body);
  }
}
```

### 6. Circuit Breaker Awareness

**Before**:
```dart
// No circuit breaker check in userService
final newTokens = await AuthService().refreshToken(refreshToken);
```

**After**:
```dart
// Check circuit breaker state
final apiClient = ApiClient('${ApiConfig.apiBaseUrl}/authentification');
if (apiClient._isCircuitBreakerOpen()) {
  // Return current token if still valid
  if (_token != null && !isTokenExpired(_token!)) {
    return _token;
  }
  return null;
}
```

### 7. Endpoint Availability Tracking

**New SharedPreferences Keys**:
- `refresh_endpoint_unavailable`: bool
- `refresh_endpoint_last_check`: timestamp

**Logic**:
- Mark endpoint unavailable on 404 responses
- Reset availability on successful refresh
- Auto-reset after 5 minutes
- Skip refresh attempts when endpoint known unavailable

### 8. Testing Checklist

- [ ] Token refresh with valid refresh token
- [ ] Token refresh with expired refresh token
- [ ] Token refresh when endpoint returns 404
- [ ] Token refresh when server returns HTML error
- [ ] Circuit breaker opening after failures
- [ ] Circuit breaker recovery after timeout
- [ ] Backup token usage when refresh fails
- [ ] User logout when all refresh methods fail
- [ ] Network connectivity issues
- [ ] Server timeout handling

### 9. Files to Update

1. **authService.dart** → **authService_improved.dart** ✅
2. **userService.dart** → **userService_improved.dart** 📝
3. **All import statements** in dependent files
4. **Test authentication flow** after changes

### 10. Expected Behavior After Fixes

1. **On 404 from refresh endpoint**:
   - Mark endpoint as unavailable
   - Continue with current token if still valid
   - Don't attempt refresh again for 5 minutes

2. **On HTML error responses**:
   - Detect HTML vs JSON responses
   - Parse errors appropriately
   - Don't crash on JSON parsing

3. **On circuit breaker open**:
   - Respect circuit breaker state
   - Don't make unnecessary API calls
   - Use current token if still valid

4. **On network errors**:
   - Retry with exponential backoff
   - Don't spam the server
   - Fail gracefully after max retries

## Summary

The fixes address the core issues:
- ✅ HTML response handling
- ✅ Endpoint availability detection
- ✅ Circuit breaker integration
- ✅ Better error categorization
- ✅ Improved retry logic

**Result**: More robust authentication that handles server errors gracefully and prevents infinite retry loops.
