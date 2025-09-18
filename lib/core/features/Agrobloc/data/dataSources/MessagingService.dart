import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart'; 
import 'package:agrobloc/core/features/Agrobloc/data/models/MessageModel.dart';

// Nouveau modèle pour la liste des conversations
class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final String receiverId;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.receiverId,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      name: json['name'],
      lastMessage: json['lastMessage'],
      receiverId: json['receiverId'],
    );
  }
}

class MessagingService {
  final ApiClient api = ApiClient(ApiConfig.apiBaseUrl);

  /// Récupère la liste des conversations pour un utilisateur donné.
  Future<List<Conversation>> getConversations(String userId) async {
    // URL de l'API fictive. Remplacez par votre endpoint réel.
    // Par exemple: final response = await api.get("/conversations/$userId");
    await Future.delayed(const Duration(seconds: 1)); // Simule un délai API

    final List<Map<String, dynamic>> jsonData = [
      {'id': 'conv_1', 'name': 'Jean Konan', 'lastMessage': 'Bonjour, j\'ai vu votre annonce...', 'receiverId': 'receiver1'},
      {'id': 'conv_2', 'name': 'Marie Diallo', 'lastMessage': 'Merci pour les informations', 'receiverId': 'receiver2'},
      {'id': 'conv_3', 'name': 'Paul Koffi', 'lastMessage': 'Quand pouvons-nous nous rencontrer ?', 'receiverId': 'receiver3'},
    ];

    return jsonData.map((json) => Conversation.fromJson(json)).toList();
  }

  /// Récupère les messages entre deux utilisateurs
  Future<List<Message>> getMessages(String userId, String receiverId) async {
    // Remplacez par votre appel API réel
    final response = await api.get("/messages/$userId/$receiverId"); 
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((m) => Message.fromJson(m)).toList();
    } else {
      throw Exception("Erreur récupération messages: ${response.body}");
    }
  }

  /// Envoie un nouveau message
  Future<Message> sendMessage(Message message) async {
    // Remplacez par votre appel API réel
    final response = await api.post(
      "/messages",
      message.toJson(), 
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur envoi message: ${response.body}");
    }
  }
}