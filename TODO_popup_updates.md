# TODO: Popup and Button Text Updates

## Tasks to Complete

### 1. Update Delete Confirmation Dialog
- [ ] Update AlertDialog in `annonce_achat_page.dart` to use green theme
- [ ] Change button colors to AppColors.primaryGreen
- [ ] Update dialog styling to match application theme

### 2. Update Form Button Text
- [ ] Change button text in `annonce_form_page.dart` from "Proposer une offre d'achat" to "Modifier une offre" when in edit mode
- [ ] Ensure button maintains green styling

### 3. Update SnackBar Colors
- [ ] Update success SnackBar backgrounds to use AppColors.primaryGreen
- [ ] Keep error SnackBar backgrounds as red

## Files to Modify
- `lib/core/features/Agrobloc/presentations/pagesAcheteurs/annonce_achat_page.dart`
- `lib/core/features/Agrobloc/presentations/widgets/acheteurs/Annonces/annonce_form_page.dart`

## Progress
- [x] Task 1: Delete Confirmation Dialog - COMPLETED
- [x] Task 2: Form Button Text - COMPLETED
- [x] Task 3: SnackBar Colors - COMPLETED

## Notes
- Primary green color: #5D9643 (AppColors.primaryGreen)
- Ensure all popups respect the application's green color scheme
- Button text should change dynamically based on edit mode
