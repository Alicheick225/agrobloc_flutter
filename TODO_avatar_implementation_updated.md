# TODO: Implémentation de l'avatar avec icône colorée

## Étapes à compléter:

### ✅ 1. Créer le widget Avatar réutilisable
- [x] Créer `lib/core/features/Agrobloc/presentations/widgets/common/avatar_widget.dart`

### 2. Mettre à jour le modèle d'authentification
- [ ] Modifier `lib/core/features/Agrobloc/data/models/authentificationModel.dart`
- [ ] Ajouter le champ `photoUrl`

### 3. Mettre à jour les services utilisateur
- [ ] Vérifier `lib/core/features/Agrobloc/data/dataSources/userService.dart`

### 4. Mettre à jour les fichiers existants
- [x] `lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/annoncePage.dart`
  - [x] Icône "œil" rendue toujours verte et cliquable
- [ ] `lib/core/features/Agrobloc/presentations/pagesAcheteurs/profilPage.dart`
- [ ] `lib/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/detail.dart`

### 5. Tests
- [ ] Tester l'affichage avec/sans photo
- [ ] Vérifier la génération des couleurs
- [ ] Tester le fallback aux initiales
