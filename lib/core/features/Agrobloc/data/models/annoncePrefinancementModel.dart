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
  final String typeCultureId; // Added for enrichment
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
    required this.typeCultureId,
    required this.adresse,
    required this.surface,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnnoncePrefinancement.fromJson(Map<String, dynamic> json) {
    // Handle quantity unit conversion
    double quantiteValue = (json['quantite'] as num?)?.toDouble() ?? 0.0;
    String quantiteUnite = 'kg';

    // If quantity is large, display in tonnes
    if (quantiteValue >= 1000) {
      quantiteUnite = 'T';
      quantiteValue = quantiteValue / 1000;
    }

    return AnnoncePrefinancement(
      id: json['id']?.toString() ?? '',
      statut: json['statut']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      montantPref: (json['montantPref'] as num?)?.toDouble() ?? 0.0,
      prixKgPref: (json['prixKgPref'] as num?)?.toDouble() ?? 0.0,
      quantite: quantiteValue,
      quantiteUnite: quantiteUnite,
      nom: json['userNom']?.toString() ?? '', // Map userNom to nom
      libelle: json['typeCultureLibelle']?.toString() ?? '', // Map typeCultureLibelle to libelle
      typeCultureId: json['typeCultureId']?.toString() ?? '', // Added for enrichment
      adresse: json['parcelleAdresse']?.toString() ?? '', // Map parcelleAdresse to adresse
      surface: (json['parcelleSuf'] as num?)?.toDouble() ?? 0.0, // Map parcelleSuf to surface
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statut': statut,
      'description': description,
      'montantPref': montantPref,
      'prixKgPref': prixKgPref,
      'quantite': quantite,
      'quantiteUnite': quantiteUnite,
      'userNom': nom, // Map nom back to userNom
      'typeCultureLibelle': libelle, // Map libelle back to typeCultureLibelle
      'typeCultureId': typeCultureId, // Added for enrichment
      'parcelleAdresse': adresse, // Map adresse back to parcelleAdresse
      'parcelleSuf': surface, // Map surface back to parcelleSuf
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
