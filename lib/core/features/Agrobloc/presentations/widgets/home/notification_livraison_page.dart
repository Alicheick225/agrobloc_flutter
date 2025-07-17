import 'package:agrobloc/core/features/Agrobloc/data/dataSources/notificationService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/notificationModel.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class NotificationLivraisonPage extends StatefulWidget {
  const NotificationLivraisonPage({super.key});

  @override
  State<NotificationLivraisonPage> createState() => _NotificationLivraisonPageState();
}

class _NotificationLivraisonPageState extends State<NotificationLivraisonPage> {
  final NotificationService _service = NotificationService();
  late Future<List<NotificationModel>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = _loadSortedNotifications();
  }

  Future<List<NotificationModel>> _loadSortedNotifications() async {
    final list = await _service.fetchNotifications();
    list.sort((a, b) => b.date.compareTo(a.date)); // Tri du plus récent au plus ancien
    return list;
  }
  void _onMenuSelected(String value) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$value sélectionné')));
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
              },
            ),

  String _formatRelative(DateTime originalDt) {
    final now = DateTime.now();
    final dt = originalDt.toLocal();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'À l’instant';
    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    }
    if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
    }
    if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    }

    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Widget _buildNotificationItem(NotificationModel notif) {
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
        children: [
          const Icon(Icons.local_shipping, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.message,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _formatRelative(notif.date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
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
              onSelected: _onMenuSelected,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'Tout marquer lu', child: Text('Tout marquer lu')),                
                PopupMenuItem(value: 'Effacer tout', child: Text('Effacer tout')),
                PopupMenuItem(value: 'Paramètres', child: Text('Paramètres')),
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
            FutureBuilder<List<NotificationModel>>(
              future: _futureNotifications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                final list = snapshot.data!;
                if (list.isEmpty) {
                  return const Center(child: Text('Aucune notification'));   
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildNotificationItem(list[index]),
                );
              },
            ),
            const Center(child: Text('Onglet Messages')),
          ],
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
          // Removed undefined 'time' variable to fix compile error
        ],
      ),
    );
  }
}
