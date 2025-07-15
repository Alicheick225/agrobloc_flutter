import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

/// Helper pour formater un DateTime en temps relatif
String _getCurrentFormattedTime(DateTime messageTime) {
  final now = DateTime.now();
  final difference = now.difference(messageTime);

  if (difference.inMinutes < 1) {
    return "à l'instant";
  } else if (difference.inMinutes < 60) {
    return "il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}";
  } else if (difference.inHours < 24) {
    return "il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}";
  } else {
    return "il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
  }
}

/// Page principale des notifications + messages
class NotificationLivraisonPage extends StatelessWidget {
  const NotificationLivraisonPage({super.key});

  // Notifications avec vraies dates
  List<Map<String, dynamic>> get notifications => [
        {
          'message': 'Commande #A00123 livrée avec succès.',
          'date': DateTime.now().subtract(const Duration(minutes: 15)),
        },
        {
          'message': 'Commande #A00124 en cours de livraison.',
          'date': DateTime.now().subtract(const Duration(minutes: 30)),
        },
        {
          'message': 'Commande #A00125 livrée à Korhogo.',
          'date': DateTime.now().subtract(const Duration(hours: 1)),
        },
      ];

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'mark_all':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Toutes les notifications marquées comme lues')),
        );
        break;
      case 'clear_all':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Toutes les notifications effacées')),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ouverture des paramètres de notifications')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: const Text('Notifications', style: TextStyle(fontSize: 18)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) => _onMenuSelected(context, value),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'mark_all', child: Text('Tout marquer lu')),
                const PopupMenuItem(value: 'clear_all', child: Text('Effacer tout')),
                const PopupMenuItem(value: 'settings', child: Text('Paramètres')),
              ],
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryGreen,
            tabs: [
              Tab(text: 'Notifications'),
              Tab(text: 'Messages'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet Notifications
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.local_shipping,
                          color: AppColors.primaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['message']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Heure : ${notif['heure']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigation vers détails
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Voir',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                return _buildNotificationItem(notif['message'], notif['date']);
              },
            ),

            // Onglet Messages
            const MessageList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String message, DateTime date) {
    final timeLabel = _getCurrentFormattedTime(date);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_shipping, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(timeLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Liste des messages (simulée)
class MessageList extends StatelessWidget {
  const MessageList({super.key});

  // Simule tes messages avec des DateTime
  List<Map<String, dynamic>> get _messagesData => [
        {
          'avatar': 'assets/images/avatar.jpg',
          'name': 'Armel Kouamé',
          'text': 'Bonsoir Monsieur, j’ai bien reçu les produits. Merci.',
          'date': DateTime.now().subtract(const Duration(hours: 1)),
        },
        // Tu peux en ajouter d'autres ici
      ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _messagesData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final msg = _messagesData[index];
        return MessageCard(
          avatar: msg['avatar'] as String,
          name: msg['name'] as String,
          message: msg['text'] as String,
          date: msg['date'] as DateTime,
        );
      },
    );
  }
}

/// Carte d’aperçu d’un message
class MessageCard extends StatelessWidget {
  final String avatar;
  final String name;
  final String message;
  final DateTime date;

  const MessageCard({
    super.key,
    required this.avatar,
    required this.name,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = _getCurrentFormattedTime(date);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessageDetailPage(
              avatar: avatar,
              name: name,
              message: message,
              date: date,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(avatar), radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(formattedTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Détail d’une conversation
class MessageDetailPage extends StatefulWidget {
  final String avatar;
  final String name;
  final String message;
  final DateTime date;

  const MessageDetailPage({
    super.key,
    required this.avatar,
    required this.name,
    required this.message,
    required this.date,
  });

  @override
  State<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': widget.message,
      'time': widget.date,
      'fromUser': false,
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'text': text,
        'time': DateTime.now(),
        'fromUser': true,
      });
    });
    _controller.clear();
  }

  void _showTimePopup(DateTime time) {
    final formatted = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} - ${time.day}/${time.month}/${time.year}";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text("Message reçu le : $formatted"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(widget.avatar), radius: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Text("En ligne", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const Spacer(),
            // Menu 3 points pour bloquer ou autres actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (v) {
                if (v == 'block') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Utilisateur ${widget.name} bloqué')),
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'block', child: Text("Bloquer l'utilisateur")),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg['fromUser'] as bool;
                final time = msg['time'] as DateTime;
                return GestureDetector(
                  onTap: () => _showTimePopup(time),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primaryGreen.withOpacity(0.2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Text(msg['text'] as String, style: const TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(height: 4),
                        Text(_getCurrentFormattedTime(time), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Écrire un message...', border: InputBorder.none)),
                ),
                IconButton(icon: const Icon(Icons.send, color: AppColors.primaryGreen), onPressed: _sendMessage),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
