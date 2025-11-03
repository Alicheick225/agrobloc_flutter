// ==========================================
// FICHIER: mesinformations_model.dart
// ==========================================

class MesInformationsModel {
  final String id;
  final String nom;
  final String? email;
  final String numeroTel;
  final String? photoPlanteur;
  final String? adresse;
  final List<String> cultures;
  final String? cooperative;

  MesInformationsModel({
    required this.id,
    required this.nom,
    this.email,
    required this.numeroTel,
    this.photoPlanteur,
    this.adresse,
    required this.cultures,
    this.cooperative,
  });

  // Factory pour créer depuis JSON
  factory MesInformationsModel.fromJson(Map<String, dynamic> json) {
    return MesInformationsModel(
      id: json['id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      email: json['email']?.toString(),
      numeroTel: json['numero_tel']?.toString() ?? '',
      photoPlanteur: json['photo_planteur']?.toString(),
      adresse: json['adresse']?.toString(),
      cultures: _parseCultures(json['cultures']),
      cooperative: json['cooperative']?.toString(),
    );
  }

  static List<String> _parseCultures(dynamic culturesData) {
    if (culturesData == null) return [];
    if (culturesData is List) {
      return culturesData.map((e) => e.toString()).toList();
    }
    if (culturesData is String) {
      return culturesData.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'numero_tel': numeroTel,
      'photo_planteur': photoPlanteur,
      'adresse': adresse,
      'cultures': cultures,
      'cooperative': cooperative,
    };
  }

  MesInformationsModel copyWith({
    String? id,
    String? nom,
    String? email,
    String? numeroTel,
    String? photoPlanteur,
    String? adresse,
    List<String>? cultures,
    String? cooperative,
  }) {
    return MesInformationsModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      numeroTel: numeroTel ?? this.numeroTel,
      photoPlanteur: photoPlanteur ?? this.photoPlanteur,
      adresse: adresse ?? this.adresse,
      cultures: cultures ?? this.cultures,
      cooperative: cooperative ?? this.cooperative,
    );
  }

  String get culturesFormatted =>
      cultures.isEmpty ? 'Aucune culture' : cultures.join(', ');

  String get telephoneFormate {
    if (numeroTel.isEmpty) return '';
    if (numeroTel.length >= 10) {
      return '+225 ${numeroTel.substring(0, 2)} ${numeroTel.substring(2, 4)} '
          '${numeroTel.substring(4, 6)} ${numeroTel.substring(6, 8)} ${numeroTel.substring(8)}';
    }
    return numeroTel;
  }

  bool get hasProfilePhoto => photoPlanteur != null && photoPlanteur!.isNotEmpty;

  String get displayName => nom.isNotEmpty ? nom : 'Utilisateur';
  String get displayEmail => email ?? 'Email non renseigné';
  String get displayAdresse => adresse ?? 'Adresse non renseignée';
  String get displayCooperative => cooperative ?? 'Aucune coopérative';

  @override
  String toString() {
    return 'MesInformationsModel(id: $id, nom: $nom, email: $email, numeroTel: $numeroTel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MesInformationsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ==========================================
// CLASSE DE RÉPONSE POUR L'API
// ==========================================

class MesInformationsResponse {
  final MesInformationsModel? user;
  final bool success;
  final String? message;
  final Map<String, dynamic>? errors;

  MesInformationsResponse({
    this.user,
    required this.success,
    this.message,
    this.errors,
  });

  factory MesInformationsResponse.fromJson(Map<String, dynamic> json) {
    return MesInformationsResponse(
      user: json['user'] != null
          ? MesInformationsModel.fromJson(json['user'])
          : null,
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  factory MesInformationsResponse.success(MesInformationsModel user,
      {String? message}) {
    return MesInformationsResponse(
      user: user,
      success: true,
      message: message,
    );
  }

  factory MesInformationsResponse.error(String message,
      {Map<String, dynamic>? errors}) {
    return MesInformationsResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }
}
