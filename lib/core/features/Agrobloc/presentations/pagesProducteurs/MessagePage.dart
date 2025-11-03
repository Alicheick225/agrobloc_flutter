import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/ConversationViewModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/discussionPage.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/MessageModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/homeProducteur.dart';

class MessagesPage extends StatefulWidget {
  final String currentUserId;
  final VoidCallback? onBackPressed;

  const MessagesPage({
    super.key,
    required this.currentUserId,
    this.onBackPressed,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ConversationViewModel _conversationViewModel = ConversationViewModel();
  late Future<List<Conversation>> _futureConversations;
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  // Charge les conversations de l'utilisateur courant
  void _loadConversations() {
    setState(() {
      _isLoading = true;
      _futureConversations = _conversationViewModel.getConversations(widget.currentUserId);
    });
  }

  // Rafraîchit la liste des conversations
  Future<void> _onRefresh() async {
    _loadConversations();
    await _futureConversations;
  }

  // Ouvre la page de discussion pour une conversation donnée
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
          recipientAvatar: conversation.avatarUrl, // Ajout de l'avatar si disponible
        ),
      ),
    );

    // Si la conversation a été marquée comme lue, recharger la liste
    if (result == true) {
      _loadConversations();
    }
  }

  // Met à jour la requête de recherche
  void _searchConversations(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Filtre les conversations selon la recherche
  List<Conversation> _getFilteredConversations() {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    return _conversations.where((conversation) {
      return conversation.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             conversation.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Récupère les initiales du nom pour l'avatar si pas d'image
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Récupère l'heure du dernier message (à améliorer avec timestamp réel)
  String _getTimeFromMessage(String lastMessage) {
    return DateTime.now().hour.toString().padLeft(2, '0') + ':' +
           DateTime.now().minute.toString().padLeft(2, '0');
  }

  // Détermine la couleur du tag selon le contenu du message
  Color _getTagColor(String message) {
    if (message.toLowerCase().contains('offre') || message.toLowerCase().contains('disponible')) {
      return Colors.green;
    } else if (message.toLowerCase().contains('transaction') || message.toLowerCase().contains('achat')) {
      return Colors.blue;
    } else if (message.toLowerCase().contains('livraison') || message.toLowerCase().contains('confirmée')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  // Texte du tag selon le contenu du message
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
        automaticallyImplyLeading: false,
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
          onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
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
        heroTag: 'producteur_new_message',
        onPressed: () {
          _showNewMessageDialog(context);
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  // Widget pour afficher un élément de conversation dans la liste
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
            // Avatar : image si disponible, sinon initiales
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                image: conversation.avatarUrl != null && conversation.avatarUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(conversation.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: conversation.avatarUrl == null || conversation.avatarUrl!.isEmpty
                  ? Center(
                      child: Text(
                        _getInitials(conversation.name),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  : null,
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

  // Affiche une boîte de dialogue pour un nouveau message (fonctionnalité en développement)
  void _showNewMessageDialog(BuildContext context) {
    // Remplacer la boîte de dialogue par une navigation vers une nouvelle page de discussion
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          conversationId: 'new', // ID fictif pour nouvelle conversation
          recipientId: '', // ID vide car pas encore choisi
          recipientName: 'Nouvelle conversation',
          currentUserId: widget.currentUserId,
          isOnline: false,
        ),
      ),
    );
  }
}

// Delegate pour la recherche de conversations
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
