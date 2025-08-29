class AnnoncePrefinancement {
  final String id;
  final String statut;
  final String description;
  final double montantPref;
  final double prixKgPref;
  final double quantite;
  final String quantiteUnite;
  final String nom; // Changed from userNom to nom
  final String libelle; // Changed from typeCultureLibelle to libelle
  final String adresse; // Changed from parcelleAdresse to adresse
  final double surface; // Changed from parcelleSuf to surface
  final DateTime createdAt;
  final DateTime updatedAt;

  AnnoncePrefinancement({
    required this.id,
    required this.statut,
    required this.description,
    required this.montantPref,
    required this.prixKgPref,
    required this.quantite,
    required this.quantiteUnite,
    required this.nom,
    required this.libelle,
    required this.adresse,
    required this.surface,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnnoncePrefinancement.fromJson(Map<String, dynamic> json) {
    // Handle quantity unit conversion
    double quantiteValue = (json['Quantite'] as num?)?.toDouble() ?? 0.0;
    String quantiteUnite = 'kg';
    
    // If quantity is large, display in tonnes
    if (quantiteValue >= 1000) {
      quantiteUnite = 'T';
      quantiteValue = quantiteValue / 1000;
    }

    return AnnoncePrefinancement(
      id: json['ID']?.toString() ?? '',
      statut: json['Statut']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      montantPref: (json['MontantPref'] as num?)?.toDouble() ?? 0.0,
      prixKgPref: (json['PrixKgPref'] as num?)?.toDouble() ?? 0.0,
      quantite: quantiteValue,
      quantiteUnite: quantiteUnite,
      nom: json['UserNom']?.toString() ?? '', // Map UserNom to nom
      libelle: json['TypeCultureLibelle']?.toString() ?? '', // Map TypeCultureLibelle to libelle
      adresse: json['ParcelleAdresse']?.toString() ?? '', // Map ParcelleAdresse to adresse
      surface: (json['ParcelleSuf'] as num?)?.toDouble() ?? 0.0, // Map ParcelleSuf to surface
      createdAt: DateTime.parse(json['CreatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['UpdatedAt']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Statut': statut,
      'Description': description,
      'MontantPref': montantPref,
      'PrixKgPref': prixKgPref,
      'Quantite': quantite,
      'QuantiteUnite': quantiteUnite,
      'UserNom': nom, // Map nom back to UserNom
      'TypeCultureLibelle': libelle, // Map libelle back to TypeCultureLibelle
      'ParcelleAdresse': adresse, // Map adresse back to ParcelleAdresse
      'ParcelleSuf': surface, // Map surface back to ParcelleSuf
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
    };
  }

  // Méthode utilitaire pour formater la quantité avec l'unité appropriée
  String get formattedQuantity {
    return '$quantite $quantiteUnite';
  }

  // Méthode utilitaire pour formater le montant avec devise
  String get formattedAmount {
    return '$montantPref FCFA';
  }

  // Méthode utilitaire pour formater le prix par kg avec devise
  String get formattedPricePerKg {
    return '$prixKgPref FCFA/kg';
  }

  // Getters for backward compatibility
  String get userNom => nom;
  String get typeCultureLibelle => libelle;
  String get parcelleAdresse => adresse;
  double get parcelleSuf => surface;
}
