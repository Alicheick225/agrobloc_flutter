# TODO: Update Remaining Services with ApiConfig

## ✅ Completed Tasks
- [x] Update avisService.dart to use ApiConfig.apiBaseUrl
- [x] Update commande_vente_service.dart to use ApiConfig.apiBaseUrl
- [ ] Add better error handling for network failures
- [x] Test configuration changes
- [x] Update TODO_api_config_fix.md with completion status

## 📋 Details
- avisService.dart: Replace hardcoded 'http://192.168.252.199:3000/' with ApiConfig.apiBaseUrl
- commande_vente_service.dart: Replace hardcoded URL with ApiConfig.apiBaseUrl (currently uses demo data)
- Add consistent error handling patterns across both services
