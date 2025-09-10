# TODO: Remove Authentication Restrictions

## Tasks
- [x] Modify annoncePage.dart to remove authentication check and login redirection
- [x] Modify offreVentePage.dart to remove authentication checks and login redirections
- [x] Check and update other form files if they have similar restrictions
- [x] Test the changes to ensure app functionality

## Files to Modify
- lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/annoncePage.dart
- lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/offreVentePage.dart
- Potentially: prefinnancementForm.dart, AnnonceForm.dart, etc.

## Goal
Remove forced login redirections when user is not authenticated, allowing app to continue functioning without authentication.
