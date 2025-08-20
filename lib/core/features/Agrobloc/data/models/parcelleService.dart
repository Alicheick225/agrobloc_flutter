// parcelle_model.dart
class Parcelle {
  final String id;
  final String libelle;
  final String geolocalisation;
  final double surface;
  final String adresse;
  final String userId;

  Parcelle({
    required this.id,
    required this.libelle,
    required this.geolocalisation,
    required this.surface,
    required this.adresse,
    required this.userId,
  });

  factory Parcelle.fromJson(Map<String, dynamic> json) {
    return Parcelle(
      id: json['id'],
      libelle: json['libelle'],
      geolocalisation: json['geolocalisation'],
      surface: (json['surface'] as num).toDouble(),
      adresse: json['adresse'],
      userId: json['user_id'],
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
    };
  }
}
