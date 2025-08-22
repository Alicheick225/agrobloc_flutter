class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime date;
  // 🆕 NOUVEAU : Champs ajoutés pour les notifications push
  final String? userId;
  final Map<String, dynamic>? payload;

  NotificationModel({
    required this.message,
    required this.date,
    required this.id,
    required this.title,
    required this.type,
    this.isRead = false,
    // 🆕 NOUVEAU : Paramètres optionnels pour les notifications push
    this.userId,
    this.payload,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(), // 🔧 MODIFIÉ : Conversion en String pour plus de flexibilité
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false, // 🔧 MODIFIÉ : Valeur par défaut
      date: DateTime.parse(json['created_at']), 
      // 🆕 NOUVEAU : Nouveaux champs pour les notifications push
      userId: json['user_id']?.toString(),
      payload: json['payload'] != null 
          ? Map<String, dynamic>.from(json['payload']) 
          : null,
    );
  }

  // 🆕 NOUVEAU : Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': date.toIso8601String(),
      'user_id': userId,
      'payload': payload,
    };
  }

  // 🆕 NOUVEAU : Méthode pour créer une copie avec modifications
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? date,
    String? userId,
    Map<String, dynamic>? payload,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      payload: payload ?? this.payload,
    );
  }
}

