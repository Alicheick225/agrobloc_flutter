# Analyse de la gestion des unités, devises et ordre d'affichage

## API Backend (Go) - Analyse

### Gestion des Unités et Devises
D'après le code Go fourni, l'API gère les unités et devises de la manière suivante :

**Quantité :**
- Stockée en `kg` dans la base de données
- Conversion automatique : si l'utilisateur saisit en tonnes (`T`), conversion en kg (*1000)
- API retourne toujours la quantité en `kg`

**Prix :**
- Toujours en `FCFA` (Franc CFA)
- Stocké comme `prix_kg` (prix par kilogramme)
- API retourne toujours le prix en `FCFA`

**Ordre d'affichage :**
- Les annonces sont triées par `created_at DESC` (du plus récent au plus ancien)
- ✅ Implémenté dans l'API avec `query.Order("created_at DESC")`

### Structure de réponse API
```json
{
  "id": "uuid",
  "statut": "string",
  "prix": 1500.0,        // FCFA par kg
  "description": "string",
  "quantite": 1000.0,    // en kg
  "userNom": "string",
  "typeCultureLibelle": "string",
  "createdAt": "2024-01-02 15:04:05"
}
```

## Frontend Flutter - Analyse

### Fichiers examinés :
1. `annoncePage.dart` - Page principale des annonces d'achat
2. `annonce_achat_page.dart` - Page des annonces utilisateur
3. `AnnonceAchatModel.dart` - Modèle de données
4. `AnnonceAchat.dart` - Service API

### Gestion des Unités et Devises dans le Frontend

**Affichage Quantité :**
```dart
// Dans annoncePage.dart et annonce_achat_page.dart
TextSpan(
  text: '${annonce.quantite} kg',  // Toujours affiché en kg
  style: const TextStyle(...),
)
```

**Affichage Prix :**
```dart
// Dans annoncePage.dart et annonce_achat_page.dart
TextSpan(
  text: '${annonce.prix} FCFA',  // Toujours affiché en FCFA
  style: const TextStyle(...),
)
```

**Modèle de données :**
```dart
// AnnonceAchatModel.dart
class AnnonceAchat {
  final double quantite;  // en kg
  final double prix;      // en FCFA
  // ...
}
```

### Ordre d'affichage dans le Frontend

**API Call :**
```dart
// AnnonceAchat.dart - fetchAnnonces()
// L'API retourne déjà les données triées par created_at DESC
final annonces = await _service.fetchAnnonces();
```

**Affichage :**
- Les annonces sont affichées dans l'ordre reçu de l'API
- Pas de tri supplémentaire dans le frontend
- ✅ L'ordre est correctement géré par l'API

### Problèmes identifiés :

1. **Conversion d'unités manquante dans le frontend** :
   - L'API convertit les tonnes en kg, mais le frontend n'affiche que des kg
   - Pas d'affichage adaptatif (tonnes pour grandes quantités)

2. **Formatage des nombres** :
   - Pas de formatage des nombres (séparateurs de milliers)
   - Exemple : 1500000 FCFA au lieu de 1 500 000 FCFA

3. **Consistance des libellés** :
   - Certains écrans utilisent "Prix unitaire", d'autres "Prix / kg"
   - Pas de standardisation

### Recommandations :

1. **Ajouter une fonction de formatage d'unités** :
```dart
String formatQuantity(double quantity) {
  if (quantity >= 1000) {
    return '${(quantity / 1000).toStringAsFixed(1)} T';
  }
  return '${quantity.toStringAsFixed(0)} kg';
}
```

2. **Ajouter un formatage monétaire** :
```dart
String formatCurrency(double amount) {
  return '${NumberFormat('#,##0').format(amount)} FCFA';
}
```

3. **Standardiser les libellés** :
   - Utiliser "Prix / kg" partout pour plus de clarté

4. **Vérifier l'ordre d'affichage** :
   - Confirmer que l'API retourne bien les annonces dans l'ordre décroissant
   - Ajouter un indicateur de tri dans le frontend si nécessaire
