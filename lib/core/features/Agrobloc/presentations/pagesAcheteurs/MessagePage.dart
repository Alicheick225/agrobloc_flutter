import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/MessagingService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/discussionPage.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/MessageModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class MessagesPage extends StatefulWidget {
  final String currentUserId;

  const MessagesPage({
    super.key,
    required this.currentUserId,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final MessagingService _messagingService = MessagingService();
  late Future<List<Conversation>> _futureConversations;
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _isLoading = true;
      _futureConversations = _messagingService.getConversations(widget.currentUserId);
    });
  }

  Future<void> _onRefresh() async {
    _loadConversations();
    await _futureConversations;
  }

  void _openChat(Conversation conversation) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          conversationId: conversation.id,
          recipientId: conversation.receiverId,
          recipientName: conversation.name,
          currentUserId: widget.currentUserId,
          isOnline: false, // Vous pouvez ajouter cette info dans votre modèle Conversation
        ),
      ),
    );

    // Si la conversation a été marquée comme lue, recharger la liste
    if (result == true) {
      _loadConversations();
    }
  }

  void _searchConversations(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Conversation> _getFilteredConversations() {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    return _conversations.where((conversation) {
      return conversation.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             conversation.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getTimeFromMessage(String lastMessage) {
    // Pour l'instant, retourne une heure par défaut
    // Vous pouvez modifier votre modèle Conversation pour inclure le timestamp
    return DateTime.now().hour.toString().padLeft(2, '0') + ':' +
           DateTime.now().minute.toString().padLeft(2, '0');
  }

  Color _getTagColor(String message) {
    // Logic pour déterminer la couleur du tag basée sur le contenu du message
    if (message.toLowerCase().contains('offre') || message.toLowerCase().contains('disponible')) {
      return Colors.green;
    } else if (message.toLowerCase().contains('transaction') || message.toLowerCase().contains('achat')) {
      return Colors.blue;
    } else if (message.toLowerCase().contains('livraison') || message.toLowerCase().contains('confirmée')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  String _getTagText(String message) {
    if (message.toLowerCase().contains('offre') || message.toLowerCase().contains('disponible')) {
      return 'Nouvelle offre';
    } else if (message.toLowerCase().contains('transaction') || message.toLowerCase().contains('achat')) {
      return 'Transaction';
    } else if (message.toLowerCase().contains('livraison') || message.toLowerCase().contains('confirmée')) {
      return 'Livraison';
    }
    return 'Message';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ConversationSearchDelegate(
                  conversations: _conversations,
                  onConversationSelected: _openChat,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryGreen,
        child: FutureBuilder<List<Conversation>>(
          future: _futureConversations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadConversations,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            _conversations = snapshot.data ?? [];
            final filteredConversations = _getFilteredConversations();

            if (filteredConversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune conversation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Commencez une nouvelle conversation',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            setState(() => _isLoading = false);

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredConversations.length,
              itemBuilder: (context, index) {
                final conversation = filteredConversations[index];
                return _buildMessageItem(conversation);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewMessageDialog(context);
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildMessageItem(Conversation conversation) {
    final tagColor = _getTagColor(conversation.lastMessage);
    final tagText = _getTagText(conversation.lastMessage);
    final time = _getTimeFromMessage(conversation.lastMessage);
    final isUnread = true; // Vous pouvez ajouter cette propriété à votre modèle

    return GestureDetector(
      onTap: () => _openChat(conversation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isUnread ? Border.all(color: Colors.blue.shade200) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  _getInitials(conversation.name),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Contenu du message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec nom et heure
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Aperçu du message
                  Text(
                    conversation.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tagText,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Nouveau Message'),
        content: const Text('Fonctionnalité en développement...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}

// Delegate pour la recherche
class ConversationSearchDelegate extends SearchDelegate<Conversation?> {
  final List<Conversation> conversations;
  final Function(Conversation) onConversationSelected;

  ConversationSearchDelegate({
    required this.conversations,
    required this.onConversationSelected,
  });

  @override
  String get searchFieldLabel => 'Rechercher des conversations...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredConversations = conversations.where((conversation) {
      return conversation.name.toLowerCase().contains(query.toLowerCase()) ||
             conversation.lastMessage.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredConversations.isEmpty) {
      return const Center(
        child: Text(
          'Aucune conversation trouvée',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            child: Text(
              conversation.name.isNotEmpty ? conversation.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          title: Text(conversation.name),
          subtitle: Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            close(context, null);
            onConversationSelected(conversation);
          },
        );
      },
    );
  }
}