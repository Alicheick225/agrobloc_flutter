// parcelle_model.dart
class Parcelle {
  final String id;
  final String libelle;
  final String geolocalisation;
  final double surface;
  final String adresse;
  final String userId;
  final String userNom; // ajoute cette propriété pour le nom de l'utilisateur

  Parcelle({
    required this.id,
    required this.libelle,
    required this.geolocalisation,
    required this.surface,
    required this.adresse,
    required this.userId,
    required this.userNom,
  });

  factory Parcelle.fromJson(Map<String, dynamic> json) {
    return Parcelle(
      id: json['id'],
      libelle: json['libelle'],
      geolocalisation: json['geolocalisation'],
      surface: (json['surface'] as num).toDouble(),
      adresse: json['adresse'],
      userId: json['user_id'],
      userNom: json['user_nom'] ?? 'Inconnu', // récupère le nom de l'utilisateur
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'geolocalisation': geolocalisation,
      'surface': surface,
      'adresse': adresse,
      'user_id': userId,
      'user_nom': userNom,
    };
  }
}
