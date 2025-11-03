class AvisAchat {
  final String id;
  final String annonceId;
  final String userId;
  final String userName;
  final String userEmail;
  final String commentaire;
  final int note;
  final DateTime createdAt;
  final DateTime updatedAt;

  AvisAchat({
    required this.id,
    required this.annonceId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.commentaire,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AvisAchat.fromJson(Map<String, dynamic> json) {
    return AvisAchat(
      id: json['id'] as String,
      annonceId: json['annonceId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      commentaire: json['commentaire'] as String,
      note: json['note'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'annonceId': annonceId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'commentaire': commentaire,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateAvisAchatRequest {
  final String annonceId;
  final String commentaire;
  final int note;

  CreateAvisAchatRequest({
    required this.annonceId,
    required this.commentaire,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'annonceId': annonceId,
      'commentaire': commentaire,
      'note': note,
    };
  }
}

class AvisAchatResponse {
  final bool success;
  final String message;
  final AvisAchat? avis;

  AvisAchatResponse({
    required this.success,
    required this.message,
    this.avis,
  });

  factory AvisAchatResponse.fromJson(Map<String, dynamic> json) {
    return AvisAchatResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      avis: json['avis'] != null ? AvisAchat.fromJson(json['avis'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'avis': avis?.toJson(),
    };
  }
}
