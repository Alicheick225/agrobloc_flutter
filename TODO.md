# TODO: Intégrer AnnonceVenteModel et AnnonceService dans offreVentePage

## Étapes à suivre :
- [x] Ajouter la méthode fetchAnnoncesByUser() à AnnonceService dans annonceVenteService.dart
- [x] Modifier offreVentePage.dart pour importer AnnonceService et AnnonceVenteModel
- [x] Remplacer l'instance de service de AnnonceAchatService à AnnonceService
- [x] Changer le modèle de AnnonceAchat à AnnonceVente
- [x] Mettre à jour la méthode _loadAnnonces pour utiliser le nouveau service
- [x] Ajuster l'interface utilisateur pour afficher les données d'annonces de vente (prixKg, etc.)
- [x] Changer le titre de l'appBar en "Mes Offres de Vente"
- [x] Mettre à jour la méthode de suppression pour utiliser deleteAnnonce d'AnnonceService
- [x] Mettre à jour la navigation d'édition pour passer AnnonceVente
- [x] Tester les modifications et vérifier l'authentification
