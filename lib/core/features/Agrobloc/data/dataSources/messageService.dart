import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import '../models/MessageModel.dart';

/// Service gérant les messages et conversations
class MessageService {
  final ApiClient api = ApiClient('${ApiConfig.messagerieBaseUrl}');

  /// Récupère une conversation par son ID
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      final response = await api.get('/conversations/$conversationId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Convertir les données de l'API en Conversation
        // Note: L'API retourne une structure différente, adapter selon besoin
        return Conversation.fromJson(data);
      } else {
        print('Erreur lors de la récupération de la conversation: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la récupération de la conversation: $e');
      return null;
    }
  }

  /// Récupère toutes les conversations
  Future<List<Conversation>> getAllConversations() async {
    print('⚠️ getAllConversations endpoint not implemented on backend');
    return [];
  }

  /// Récupère les conversations d'un participant
  Future<List<Conversation>> getConversationsByParticipant(String participantId) async {
    try {
      final response = await api.get('/conversations/participant/$participantId');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        // API returns 400 when no conversations exist for the participant
        print('Aucune conversation trouvée pour le participant $participantId');
        return [];
      } else {
        print('Erreur lors de la récupération des conversations du participant: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des conversations du participant: $e');
      return [];
    }
  }

  /// Crée ou met à jour une conversation
  Future<Conversation?> saveConversation(Conversation conversation) async {
    try {
      final conversationData = {
        'order_id': conversation.id, // Adapter selon la structure de l'API
        'payment_id': null, // Adapter selon besoin
        'participants': conversation.participants,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await api.post('/conversations', conversationData,);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Conversation.fromJson(data);
      } else {
        print('Erreur lors de la sauvegarde de la conversation: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la sauvegarde de la conversation: $e');
      return null;
    }
  }

  /// Envoie un message dans une conversation
  Future<Message?> sendMessage(String conversationId, Message message) async {
    try {
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': message.senderId,
        'recipient_id': message.receiverId,
        'content': message.content,
        'message_type': message.messageType.value,
        'status': message.status.value,
        'created_at': message.timestamp.toIso8601String(),
        'updated_at': message.timestamp.toIso8601String(),
      };

      final response = await api.post('/conversations/$conversationId/messages', messageData,);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // L'API devrait retourner le message créé avec un ID
        return Message.fromJson(data, message.senderId);
      } else {
        print('Erreur lors de l\'envoi du message: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de l\'envoi du message: $e');
      return null;
    }
  }

  /// Récupère les messages d'une conversation
  Future<List<Message>> getMessages(String conversationId, String currentUserId) async {
    try {
      final response = await api.get('/conversations/$conversationId/messages');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Message.fromJson(json, currentUserId)).toList();
      } else {
        print('Erreur lors de la récupération des messages: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des messages: $e');
      return [];
    }
  }

  /// Supprime une conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await api.delete('/conversations/$conversationId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Erreur lors de la suppression de la conversation: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception lors de la suppression de la conversation: $e');
      return false;
    }
  }

  /// Marque les messages comme lus dans une conversation
  Future<bool> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final response = await api.put('/conversations/$conversationId/read', {
        'user_id': userId,
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erreur lors du marquage des messages comme lus: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception lors du marquage des messages comme lus: $e');
      return false;
    }
  }

  /// Recherche des conversations par terme
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      final response = await api.get('/conversations/search?q=$query');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else {
        print('Erreur lors de la recherche de conversations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la recherche de conversations: $e');
      return [];
    }
  }
}
