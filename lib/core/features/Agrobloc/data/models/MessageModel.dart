import 'dart:convert';

/// Énumération pour les types de messages
enum MessageType {
  text,
  image,
  file,
  audio,
  video,
}

/// Énumération pour les statuts de messages
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Extension pour convertir les énumérations en String et vice versa
extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.audio:
        return 'audio';
      case MessageType.video:
        return 'video';
    }
  }

  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      default:
        return MessageType.text;
    }
  }
}

extension MessageStatusExtension on MessageStatus {
  String get value {
    switch (this) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
    }
  }

  static MessageStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }
}

/// Modèle principal pour un message
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageType messageType;
  final MessageStatus status;
  final bool isFromCurrentUser;
  final String? conversationId;
  final Map<String, dynamic>? metadata; // Pour des données supplémentaires (taille fichier, etc.)

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isFromCurrentUser,
    this.messageType = MessageType.text,
    this.status = MessageStatus.sent,
    this.conversationId,
    this.metadata,
  });

  /// Factory constructor pour créer un Message depuis JSON
  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      id: json['_id']?.toString() ?? 
          json['id']?.toString() ?? 
          json['message_id']?.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: json['senderId']?.toString() ?? 
                json['sender_id']?.toString() ?? 
                json['from']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? 
                  json['recipient_id']?.toString() ?? 
                  json['to']?.toString() ?? '',
      content: json['content']?.toString() ?? 
               json['message']?.toString() ?? 
               json['text']?.toString() ?? '',
      timestamp: _parseTimestamp(json['timestamp'] ?? 
                                json['created_at'] ?? 
                                json['sent_at'] ?? 
                                DateTime.now().toIso8601String()),
      messageType: MessageTypeExtension.fromString(
        json['messageType']?.toString() ?? 
        json['message_type']?.toString() ?? 
        json['type']?.toString() ?? 
        'text'
      ),
      status: MessageStatusExtension.fromString(
        json['status']?.toString() ?? 'sent'
      ),
      conversationId: json['conversationId']?.toString() ?? 
                      json['conversation_id']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isFromCurrentUser: (json['senderId']?.toString() ?? 
                         json['sender_id']?.toString() ?? 
                         json['from']?.toString() ?? '') == currentUserId,
    );
  }

  /// Constructeur pour créer un nouveau message à envoyer
  Message.create({
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = MessageType.text,
    this.conversationId,
    this.metadata,
  }) : id = '', // L'ID sera assigné par le serveur
       timestamp = DateTime.now(),
       status = MessageStatus.sending,
       isFromCurrentUser = true;

  /// Convertit le Message en JSON pour l'API
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'sender_id': senderId,
      'recipient_id': receiverId,
      'content': content,
      'message_type': messageType.value,
      'status': status.value,
      'created_at': timestamp.toIso8601String(),
    };

    // Ajoute l'ID seulement s'il existe (pour les mises à jour)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Ajoute conversation_id s'il existe
    if (conversationId != null && conversationId!.isNotEmpty) {
      json['conversation_id'] = conversationId;
    }

    // Ajoute les métadonnées s'elles existent
    if (metadata != null && metadata!.isNotEmpty) {
      json['metadata'] = metadata;
    }

    return json;
  }

  /// Méthode pour copier un message avec des modifications
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    MessageType? messageType,
    MessageStatus? status,
    bool? isFromCurrentUser,
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
      conversationId: conversationId ?? this.conversationId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Méthode pour parser les timestamps de différents formats
  static DateTime _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return DateTime.now();
    
    if (timestampData is DateTime) return timestampData;
    
    if (timestampData is String) {
      try {
        return DateTime.parse(timestampData);
      } catch (e) {
        print('Erreur parsing timestamp: $timestampData');
        return DateTime.now();
      }
    }
    
    if (timestampData is int) {
      // Timestamp en millisecondes ou secondes
      if (timestampData > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(timestampData);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(timestampData * 1000);
      }
    }
    
    return DateTime.now();
  }

  @override
  String toString() {
    return 'Message{id: $id, senderId: $senderId, content: $content, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modèle pour une conversation
class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final String receiverId;
  final DateTime? lastMessageTime;
  final String? avatarUrl;
  final int unreadCount;
  final bool isOnline;
  final List<String> participants;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.receiverId,
    this.lastMessageTime,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isOnline = false,
    this.participants = const [],
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Handle the API response format with participants and messages arrays
    final participants = json['participants'] as List<dynamic>? ?? [];
    final messages = json['messages'] as List<dynamic>? ?? [];

    String name = 'Conversation';
    String receiverId = '';
    String lastMessage = '';
    DateTime? lastMessageTime;

    // Extract participant info
    if (participants.isNotEmpty) {
      final participant = participants[0] as Map<String, dynamic>;
      name = participant['name']?.toString() ?? 'Utilisateur';
      receiverId = participant['id']?.toString() ?? '';
    }

    // Extract last message info
    if (messages.isNotEmpty) {
      final message = messages[0] as Map<String, dynamic>;
      lastMessage = message['content']?.toString() ?? '';
      lastMessageTime = Message._parseTimestamp(message['created_at'] ?? message['updated_at']);
    } else {
      // Fallback to conversation timestamps
      lastMessageTime = json['updated_at'] != null
        ? Message._parseTimestamp(json['updated_at'])
        : (json['created_at'] != null
            ? Message._parseTimestamp(json['created_at'])
            : null);
    }

    return Conversation(
      id: json['id']?.toString() ?? '',
      name: name,
      lastMessage: lastMessage,
      receiverId: receiverId,
      lastMessageTime: lastMessageTime,
      avatarUrl: null, // Not provided in this API format
      unreadCount: 0, // Not provided in this API format
      isOnline: false, // Not provided in this API format
      participants: participants.map((p) => (p as Map<String, dynamic>)['id']?.toString() ?? '').toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last_message': lastMessage,
      'recipient_id': receiverId,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'avatar_url': avatarUrl,
      'unread_count': unreadCount,
      'is_online': isOnline,
      'participants': participants,
    };
  }

  Conversation copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? receiverId,
    DateTime? lastMessageTime,
    String? avatarUrl,
    int? unreadCount,
    bool? isOnline,
    List<String>? participants,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      receiverId: receiverId ?? this.receiverId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      participants: participants ?? this.participants,
    );
  }

  @override
  String toString() {
    return 'Conversation{id: $id, name: $name, lastMessage: $lastMessage}';
  }
}

/// Modèle pour transformer les messages de l'API en conversations
class ConversationFromMessage {
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String content;
  final String messageType;
  final String status;
  final DateTime createdAt;
  final String? senderName;
  final String? recipientName;

  ConversationFromMessage({
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.messageType,
    required this.status,
    required this.createdAt,
    this.senderName,
    this.recipientName,
  });

  factory ConversationFromMessage.fromJson(Map<String, dynamic> json) {
    return ConversationFromMessage(
      conversationId: json['conversation_id']?.toString() ?? 
                     json['conversationId']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? 
                json['senderId']?.toString() ?? '',
      recipientId: json['recipient_id']?.toString() ?? 
                   json['recipientId']?.toString() ?? '',
      content: json['content']?.toString() ?? 
               json['message']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? 
                   json['messageType']?.toString() ?? 'text',
      status: json['status']?.toString() ?? 'sent',
      createdAt: Message._parseTimestamp(json['created_at'] ?? 
                                        json['timestamp'] ?? 
                                        DateTime.now().toIso8601String()),
      senderName: json['sender_name']?.toString() ?? 
                  json['senderName']?.toString(),
      recipientName: json['recipient_name']?.toString() ?? 
                     json['recipientName']?.toString(),
    );
  }

  /// Convertit en Conversation pour l'affichage dans la liste
  Conversation toConversation(String currentUserId, {String? recipientName}) {
    // Détermine qui est l'autre participant
    final isCurrentUserSender = senderId == currentUserId;
    final otherParticipantId = isCurrentUserSender ? recipientId : senderId;
    final otherParticipantName = isCurrentUserSender ? 
        (this.recipientName ?? recipientName) : 
        (this.senderName ?? recipientName);
    
    return Conversation(
      id: conversationId,
      name: otherParticipantName ?? 'Utilisateur $otherParticipantId',
      lastMessage: content,
      receiverId: otherParticipantId,
      lastMessageTime: createdAt,
      participants: [senderId, recipientId],
    );
  }
}

/// Classe utilitaire pour les opérations sur les messages
class MessageUtils {
  /// Formate l'heure d'un message pour l'affichage
  static String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      // Aujourd'hui : affiche juste l'heure
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Hier
      return 'Hier';
    } else if (now.difference(messageDate).inDays < 7) {
      // Cette semaine : jour de la semaine
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[timestamp.weekday - 1];
    } else {
      // Plus ancien : date complète
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Vérifie si deux messages doivent être groupés (même expéditeur, temps proche)
  static bool shouldGroupMessages(Message? previous, Message current) {
    if (previous == null) return false;
    if (previous.senderId != current.senderId) return false;
    
    final timeDiff = current.timestamp.difference(previous.timestamp);
    return timeDiff.inMinutes < 5; // Groupe si moins de 5 minutes d'écart
  }

  /// Vérifie si un séparateur de date doit être affiché
  static bool shouldShowDateSeparator(Message? previous, Message current) {
    if (previous == null) return true;
    
    final previousDate = DateTime(
      previous.timestamp.year,
      previous.timestamp.month,
      previous.timestamp.day,
    );
    final currentDate = DateTime(
      current.timestamp.year,
      current.timestamp.month,
      current.timestamp.day,
    );
    
    return previousDate != currentDate;
  }
}