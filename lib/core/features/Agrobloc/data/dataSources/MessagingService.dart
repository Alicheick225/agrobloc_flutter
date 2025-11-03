import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrobloc/core/utils/api_token.dart'; 
import 'package:agrobloc/core/features/Agrobloc/data/models/MessageModel.dart';

class MessagingService {
  static const String _baseUrl = "http://192.168.252.183:8087";

  /// Récupère le token depuis SharedPreferences
  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? prefs.getString('token') ?? '';
  }

  /// ATTENTION : Cette méthode ne peut pas fonctionner car votre API n'a pas d'endpoint 
  /// pour récupérer les conversations. Vous devez soit :
  /// 1. Demander à votre équipe backend d'ajouter un endpoint GET /conversations
  /// 2. Stocker localement les conversations
  /// 3. Utiliser un endpoint différent qui existe sur votre API
  Future<List<Conversation>> getUserConversations(String userId, {String? token}) async {
    try {
      // PROBLÈME : Cet endpoint n'existe pas dans votre API
      // Vous devez créer l'endpoint côté backend ou utiliser une autre approche
      
      print("⚠️ ERREUR : L'endpoint /conversations n'existe pas sur votre API");
      print("⚠️ Votre API a seulement : /conversations/{Id}/messages");
      print("⚠️ Solutions possibles :");
      print("   1. Ajouter GET /conversations sur votre backend");
      print("   2. Ajouter GET /users/{userId}/conversations sur votre backend");
      print("   3. Stocker les conversations localement dans l'app");
      
      // Pour l'instant, retourne une liste vide pour éviter le crash
      return [];
      
      // Si vous avez un autre endpoint qui liste les conversations, 
      // remplacez cette ligne par le bon endpoint :
      // final url = Uri.parse("$_baseUrl/votre-endpoint-conversations");
      
    } catch (e) {
      print("Erreur lors de la récupération des conversations: $e");
      return []; // Retourne une liste vide au lieu de faire planter l'app
    }
  }

  /// Méthode alternative pour récupérer les conversations (nom plus court)
  Future<List<Conversation>> getConversations(String userId, {String? token}) async {
    return getUserConversations(userId, token: token);
  }

  /// Récupère les messages d'une conversation spécifique
  /// CETTE MÉTHODE DEVRAIT FONCTIONNER avec votre API
  Future<List<Message>> getConversationMessages(String conversationId, String currentUserId, {String? token}) async {
    try {
      final authToken = token ?? await _getAuthToken();
      
      if (authToken.isEmpty) {
        throw Exception("Token d'autorisation manquant");
      }
      
      // Utilise votre endpoint correct
      final url = Uri.parse("$_baseUrl/conversations/$conversationId/messages");
      
      print("Récupération des messages depuis: ${url.toString()}");
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      
      print("Réponse API messages - Status: ${response.statusCode}");
      print("Réponse API messages - Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List data = responseBody is List ? responseBody : responseBody['messages'] ?? responseBody['data'] ?? [];
        
        // Transforme les messages de l'API vers votre modèle Message
        return data.map((item) {
          final messageMap = item as Map<String, dynamic>;
          
          // Adapte les champs de votre API vers votre modèle Message
          final adaptedMessage = {
            '_id': messageMap['id']?.toString() ?? messageMap['_id']?.toString() ?? '',
            'senderId': messageMap['sender_id']?.toString() ?? messageMap['senderId']?.toString() ?? '',
            'receiverId': messageMap['recipient_id']?.toString() ?? messageMap['receiverId']?.toString() ?? '',
            'content': messageMap['content']?.toString() ?? messageMap['message']?.toString() ?? '',
            'timestamp': messageMap['created_at'] ?? messageMap['timestamp'] ?? DateTime.now().toIso8601String(),
            'messageType': messageMap['message_type'] ?? messageMap['messageType'] ?? 'text',
            'status': messageMap['status'] ?? 'sent',
            'conversationId': conversationId, // Ajoute l'ID de conversation
          };
          
          return Message.fromJson(adaptedMessage, currentUserId);
        }).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Trie par ordre chronologique
        
      } else if (response.statusCode == 401) {
        throw Exception("Token d'autorisation invalide ou expiré");
      } else if (response.statusCode == 404) {
        print("Conversation $conversationId non trouvée");
        return [];
      } else {
        throw Exception("Erreur récupération messages: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des messages: $e");
      rethrow;
    }
  }

  /// Méthode corrigée pour correspondre à l'appel dans ChatPage
  /// ATTENTION: Les paramètres étaient inversés dans votre ChatPage
  Future<List<Message>> getMessages(String currentUserId, String recipientId, {String? token}) async {
    // Pour l'instant, on doit deviner ou construire le conversationId
    // Vous devez définir comment construire l'ID de conversation
    // Exemples possibles :
    String conversationId;
    
    // Option 1: Concaténation des IDs triés (plus petit en premier)
    if (currentUserId.compareTo(recipientId) < 0) {
      conversationId = "${currentUserId}_$recipientId";
    } else {
      conversationId = "${recipientId}_$currentUserId";
    }
    
    // Option 2: Si vous avez un autre système d'ID, remplacez par votre logique
    // conversationId = "votre_logique_id";
    
    print("ID de conversation généré: $conversationId");
    
    return getConversationMessages(conversationId, currentUserId, token: token);
  }

  /// Envoie un nouveau message dans une conversation
  /// CETTE MÉTHODE DEVRAIT FONCTIONNER avec votre API mais vous devez d'abord créer la conversation
  Future<Message> sendMessage(Message message, {String conversationId = '', String? token}) async {
    try {
      final authToken = token ?? await _getAuthToken();
      
      if (authToken.isEmpty) {
        throw Exception("Token d'autorisation manquant");
      }
      
      // Construction de l'ID de conversation si pas fourni
      String finalConversationId = conversationId;
      if (finalConversationId.isEmpty) {
        if (message.conversationId != null && message.conversationId!.isNotEmpty) {
          finalConversationId = message.conversationId!;
        } else {
          // Génère l'ID de conversation comme dans getMessages
          if (message.senderId.compareTo(message.receiverId) < 0) {
            finalConversationId = "${message.senderId}_${message.receiverId}";
          } else {
            finalConversationId = "${message.receiverId}_${message.senderId}";
          }
        }
      }
      
      final url = Uri.parse("$_baseUrl/conversations/$finalConversationId/messages");
      
      print("Envoi de message vers: ${url.toString()}");
      print("Données du message: ${jsonEncode(message.toJson())}");
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(message.toJson()),
      );

      print("Réponse API envoi message - Status: ${response.statusCode}");
      print("Réponse API envoi message - Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        // Adapte la réponse à votre modèle
        final adaptedResponse = {
          '_id': responseBody['id']?.toString() ?? responseBody['_id']?.toString() ?? '',
          'senderId': responseBody['sender_id']?.toString() ?? message.senderId,
          'receiverId': responseBody['recipient_id']?.toString() ?? message.receiverId,
          'content': responseBody['content']?.toString() ?? message.content,
          'timestamp': responseBody['created_at'] ?? DateTime.now().toIso8601String(),
          'messageType': responseBody['message_type'] ?? 'text',
          'status': responseBody['status'] ?? 'sent',
          'conversationId': finalConversationId,
        };
        
        return Message.fromJson(adaptedResponse, message.senderId);
      } else if (response.statusCode == 401) {
        throw Exception("Token d'autorisation invalide ou expiré");
      } else if (response.statusCode == 404) {
        throw Exception("Conversation non trouvée. Vous devez peut-être créer la conversation d'abord.");
      } else {
        throw Exception("Erreur envoi message: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de l'envoi du message: $e");
      rethrow;
    }
  }

  /// Version alternative de sendMessage avec conversationId en premier paramètre
  Future<Message> sendMessageToConversation(String conversationId, Message message, {String? token}) async {
    return sendMessage(message, conversationId: conversationId, token: token);
  }

  /// ATTENTION: Cette méthode ne peut probablement pas fonctionner 
  /// car votre API n'a pas d'endpoint pour créer des conversations
  Future<Conversation> createConversation(String userId, String receiverId, {String? token}) async {
    print("⚠️ ATTENTION: Votre API n'a peut-être pas d'endpoint pour créer des conversations");
    print("⚠️ Vous devez vérifier si POST /conversations existe sur votre backend");
    
    try {
      final authToken = token ?? await _getAuthToken();
      
      if (authToken.isEmpty) {
        throw Exception("Token d'autorisation manquant");
      }
      
      final url = Uri.parse("$_baseUrl/conversations");
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'participants': [userId, receiverId],
        }),
      );

      print("Réponse API création conversation - Status: ${response.statusCode}");
      print("Réponse API création conversation - Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return Conversation.fromJson(responseBody);
      } else if (response.statusCode == 404) {
        // Si l'endpoint n'existe pas, crée une conversation "virtuelle"
        print("Endpoint de création de conversation non trouvé, création d'une conversation locale");
        final conversationId = userId.compareTo(receiverId) < 0 
            ? "${userId}_$receiverId" 
            : "${receiverId}_$userId";
            
        return Conversation(
          id: conversationId,
          name: "Conversation",
          lastMessage: "",
          receiverId: receiverId,
          participants: [userId, receiverId],
        );
      } else {
        throw Exception("Erreur création conversation: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de la création de la conversation: $e");
      rethrow;
    }
  }
}