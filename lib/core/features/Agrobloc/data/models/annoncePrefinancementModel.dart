class AnnoncePrefinancement {
  final String id;
  final String statut;
  final String description;
  final double montantPref;
  final double prixKgPref;
  final double quantite;
  final String quantiteUnite;
  final String nom; // Changed from userNom to nom
  final String libelle; // Changed from cultureLibelle to libelle
  final String cultureId; // Added for enrichment
  final String parcelleId; // Added for parcelle ID
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
    required this.cultureId,
    required this.parcelleId,
    required this.adresse,
    required this.surface,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to parse double from various types (num or String)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory AnnoncePrefinancement.fromJson(Map<String, dynamic> json) {
    print('🔍 AnnoncePrefinancement.fromJson: JSON complet reçu: $json');

    // Handle quantity unit conversion
    double quantiteValue = _parseDouble(json['quantite']) ?? 0.0;
    String quantiteUnite = json['unite']?.toString() ?? 'kg';

    // Extract nested culture data (updated from type_culture to culture)
    String libelle = '';
    if (json['culture'] != null && json['culture'] is Map<String, dynamic>) {
      final culture = json['culture'] as Map<String, dynamic>;
      libelle = culture['libelle']?.toString() ?? '';
      print('✅ AnnoncePrefinancement.fromJson: Libelle extrait du culture imbriqué: "$libelle"');
    } else {
      print('⚠️ AnnoncePrefinancement.fromJson: Pas de culture imbriqué trouvé');
    }

    // Fallback to direct field if nested data is empty
    if (libelle.isEmpty) {
      libelle = json['libelle']?.toString() ?? '';
      print('🔄 AnnoncePrefinancement.fromJson: Utilisation du fallback libelle direct: "$libelle"');
    }

    print('🔍 AnnoncePrefinancement.fromJson: Libelle final après extraction: "$libelle"');

    // Try multiple possible field names for cultureId (updated from type_culture_id to culture_id and type_culture to culture)
    String cultureId = '';
    if (json['culture_id'] != null) {
      cultureId = json['culture_id'].toString();
    } else if (json['cultureId'] != null) {
      cultureId = json['cultureId'].toString();
    } else if (json['culture'] != null && json['culture'] is Map<String, dynamic>) {
      final culture = json['culture'] as Map<String, dynamic>;
      cultureId = culture['id']?.toString() ?? '';
    }

    print('🔍 AnnoncePrefinancement.fromJson: cultureId extrait: "$cultureId"');

    // Extract parcelleId
    String parcelleId = '';
    if (json['parcelle_id'] != null) {
      parcelleId = json['parcelle_id'].toString();
    } else if (json['parcelleId'] != null) {
      parcelleId = json['parcelleId'].toString();
    } else if (json['parcelle'] != null && json['parcelle'] is Map<String, dynamic>) {
      final parcelle = json['parcelle'] as Map<String, dynamic>;
      parcelleId = parcelle['id']?.toString() ?? '';
    }

    print('🔍 AnnoncePrefinancement.fromJson: parcelleId extrait: "$parcelleId"');

    return AnnoncePrefinancement(
      id: json['id']?.toString() ?? '',
      statut: json['statut']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      montantPref: _parseDouble(json['montant_pref']) ?? 0.0,
      prixKgPref: _parseDouble(json['prix_kg_pref']) ?? 0.0,
      quantite: quantiteValue,
      quantiteUnite: quantiteUnite,
      nom: json['UserNom']?.toString() ?? json['nom']?.toString() ?? json['userNom']?.toString() ?? '', // Use API field UserNom, with fallbacks
      libelle: json['CultureLibelle']?.toString() ?? libelle, // Use API field CultureLibelle, fallback to extracted libelle
      cultureId: cultureId, // Use extracted cultureId variable
      parcelleId: parcelleId, // Use extracted parcelleId variable
      adresse: json['Adresse']?.toString() ?? json['adresse']?.toString() ?? json['parcelleAdresse']?.toString() ?? '', // Use API field ParcelleAdresse, with fallbacks
      surface: _parseDouble(json['ParcelleSuf']) ?? _parseDouble(json['surface']) ?? _parseDouble(json['parcelleSuf']) ?? 0.0, // Use API field ParcelleSuf, with fallbacks
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statut': statut,
      'description': description,
      'montant_pref': montantPref,
      'prix_kg_pref': prixKgPref,
      'quantite': quantite,
      'quantiteUnite': quantiteUnite,
      'userNom': nom, // Map nom back to userNom
      'cultureLibelle': libelle, // Map libelle back to cultureLibelle
      'type_culture_id': cultureId, // Added for enrichment
      'parcelleAdresse': adresse, // Map adresse back to parcelleAdresse
      'parcelleSuf': surface, // Map surface back to parcelleSuf
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
  String get cultureLibelle => libelle;
  String get parcelleAdresse => adresse;
  double get parcelleSuf => surface;
}
