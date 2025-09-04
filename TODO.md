# TODO: Fix Prefinancement Offers Retrieval and Form Navigation

## Issues to Address:
1. Prefinancement offers are not filtered by user - currently fetches all offers
2. "Voir ma demande" button navigates to wrong route
3. "Retour" button doesn't reset form fields

## Tasks:
- [ ] Add `fetchPrefinancementsByUser(String userId)` method to `PrefinancementService`
- [ ] Update `offreVentePage.dart` to use user-filtered method for prefinancements
- [ ] Update `prefinancementForm.dart` navigation for "voir ma demande" button
- [ ] Add form reset functionality to "retour" button in dialog
- [ ] Test the complete flow

## Files to Modify:
- lib/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart
- lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/offreVentePage.dart
- lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/prefinancementForm.dart
