class AnnonceFinancement {
  final String id;
  final String statut;
  final String description;
  final double montantPref;
  final double prixKgPref;
  final double quantite;
  final String nom;
  final String libelle;
  final String adresse;
  final double surface;

  AnnonceFinancement({
    required this.id,
    required this.statut,
    required this.description,
    required this.montantPref,
    required this.prixKgPref,
    required this.quantite,
    required this.nom,
    required this.libelle,
    required this.adresse,
    required this.surface,
  });

  factory AnnonceFinancement.fromJson(Map<String, dynamic> json) {
    return AnnonceFinancement(
      id: json['id'],
      statut: json['statut'] ?? '',
      description: json['description'] ?? '',
      montantPref: (json['montant_pref'] as num?)?.toDouble() ?? 0,
      prixKgPref: (json['prix_kg_pref'] as num?)?.toDouble() ?? 0,
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0,
      nom: json['nom'] ?? '',
      libelle: json['libelle'] ?? '',
      adresse: json['adresse'] ?? '',
      surface: double.tryParse(json['surface'] ?? '0') ?? 0,
    );
  }
}
