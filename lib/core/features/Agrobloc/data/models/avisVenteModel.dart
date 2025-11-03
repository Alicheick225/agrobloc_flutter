class AvisVenteModel {
  final String id;
  final double note;
  final String titre;
  final String? commentaire;
  final String annoncesVenteId;
  final String userId;
  final String userName;
  final String userPhoto;
  final DateTime createdAt;
  final DateTime updatedAt;

  AvisVenteModel({
    required this.id,
    required this.note,
    required this.titre,
    this.commentaire,
    required this.annoncesVenteId,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AvisVenteModel.fromJson(Map<String, dynamic> json) {
    return AvisVenteModel(
      id: json['id'],
      note: (json['note'] as num).toDouble(),
      titre: json['titre'],
      commentaire: json['commentaire'],
      annoncesVenteId: json['annonces_vente_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? '',
      userPhoto: json['user_photo'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'titre': titre,
      'commentaire': commentaire,
      'annonces_vente_id': annoncesVenteId,
      'user_id': userId,
      'user_name': userName,
      'user_photo': userPhoto,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreateAvisVenteRequest {
  final double note;
  final String titre;
  final String? commentaire;
  final String annoncesVenteId;

  CreateAvisVenteRequest({
    required this.note,
    required this.titre,
    this.commentaire,
    required this.annoncesVenteId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'note': note,
      'titre': titre,
      'annonces_vente_id': annoncesVenteId,
    };
    
    if (commentaire != null && commentaire!.isNotEmpty) {
      data['commentaire'] = commentaire;
    }
    
    return data;
  }
}

class AvisVenteResponse {
  final bool success;
  final String message;
  final AvisVenteModel? data;

  AvisVenteResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AvisVenteResponse.fromJson(Map<String, dynamic> json) {
    return AvisVenteResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: json['data'] != null ? AvisVenteModel.fromJson(json['data']) : null,
    );
  }
}

class ListAvisVenteResponse {
  final bool success;
  final String message;
  final List<AvisVenteModel> data;
  final int total;
  final int page;
  final int limit;

  ListAvisVenteResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory ListAvisVenteResponse.fromJson(Map<String, dynamic> json) {
    return ListAvisVenteResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => AvisVenteModel.fromJson(item))
          .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }
}