class AnnoncePrefinancement {
  final String id;
  final String statut;
  final String description;
  final double montantPref;
  final double prixKgPref;
  final double quantite;
  final String nom;
  final String libelle;
  final String adresse;
  final String surface;

  AnnoncePrefinancement({
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

  factory AnnoncePrefinancement.fromJson(Map<String, dynamic> json) {
    return AnnoncePrefinancement(
      id: json['id'],
      statut: json['statut'],
      description: json['description'],
      montantPref: (json['montant_pref'] as num).toDouble(),
      prixKgPref: (json['prix_kg_pref'] as num).toDouble(),
      quantite: (json['quantite'] as num).toDouble(),
      nom: json['nom'],
      libelle: json['libelle'],
      adresse: json['adresse'],
      surface: json['surface'].toString(),
    );
  }

  Object? toJson() {
    return null;
  }
}
