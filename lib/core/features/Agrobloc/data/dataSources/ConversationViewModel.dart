import 'package:agrobloc/core/features/Agrobloc/data/dataSources/messageService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/MessageModel.dart';

class ConversationViewModel {
  final MessageService _messageService = MessageService();

  // Méthode pour récupérer les conversations d'un utilisateur
  Future<List<Conversation>> getConversations(String userId) {
    return _messageService.getConversationsByParticipant(userId);
  }
  }