import 'package:agrobloc/core/features/Agrobloc/data/dataSources/notificationService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/notificationModel.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class NotificationLivraisonPage extends StatefulWidget {
  final String? userId;

  const NotificationLivraisonPage({
    super.key,
    this.userId,
  });

  @override
  State<NotificationLivraisonPage> createState() =>
      _NotificationLivraisonPageState();
}

class _NotificationLivraisonPageState
    extends State<NotificationLivraisonPage> {
  final NotificationService _service = NotificationService();
  late Future<List<NotificationModel>> _futureNotifications;

  bool _isPushEnabled = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _futureNotifications = _loadSortedNotifications();
    _initializePushNotifications();
  }

  Future<void> _initializePushNotifications() async {
    setState(() => _isInitializing = true);

    try {
      await _service.initializePushNotifications();

      _service.onNewNotification = (notification) {
        _refreshNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nouvelle notification: ${notification.title}'),
              duration: const Duration(seconds: 3),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      };

      if (widget.userId != null) {
        final registered = await _service.registerDeviceToken(widget.userId!);
        if (registered) {
          await _service.startListening(userId: widget.userId);
          setState(() => _isPushEnabled = true);
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur initialisation push: $e');
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  void _refreshNotifications() {
    setState(() {
      _futureNotifications = _loadSortedNotifications();
    });
  }

  Future<List<NotificationModel>> _loadSortedNotifications() async {
    final list = await _service.fetchNotifications();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'mark_all':
        if (widget.userId != null) {
          await _service.markAllAsRead(widget.userId!);
          _refreshNotifications();
          _showMessage('Toutes les notifications marquées comme lues');
        }
        break;
      case 'clear_all':
        _showMessage('Fonction à implémenter');
        break;
      case 'settings':
        _showMessage('Paramètres à implémenter');
        break;
      case 'toggle_push':
        await _togglePushNotifications();
        break;
    }
  }

  Future<void> _togglePushNotifications() async {
    if (widget.userId == null) {
      _showMessage('ID utilisateur requis pour les notifications push');
      return;
    }

    if (_isPushEnabled) {
      _service.stopListening();
      setState(() => _isPushEnabled = false);
      _showMessage('Notifications push désactivées');
    } else {
      final registered = await _service.registerDeviceToken(widget.userId!);
      if (registered) {
        await _service.startListening(userId: widget.userId);
        setState(() => _isPushEnabled = true);
        _showMessage('Notifications push activées');
      } else {
        _showMessage('Erreur lors de l\'activation');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatRelative(DateTime originalDt) {
    final now = DateTime.now();
    final dt = originalDt.toLocal();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'À l\'instant';
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
    return GestureDetector(
      onTap: () async {
        if (!notif.isRead && widget.userId != null) {
          await _service.markAsRead(notif.id);
          _refreshNotifications();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead
                ? Colors.grey.shade300
                : AppColors.primaryGreen.withOpacity(0.3),
          ),
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
            Icon(
              _getNotificationIcon(notif.type),
              color: notif.isRead ? Colors.grey : AppColors.primaryGreen,
            ),
            const SizedBox(width: 12),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
            if (!notif.isRead) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          notif.isRead ? FontWeight.w400 : FontWeight.w600,
                      color:
                          notif.isRead ? Colors.grey.shade600 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color:
                          notif.isRead ? Colors.grey.shade500 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatRelative(notif.date),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
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

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'livraison':
      case 'delivery':
        return Icons.local_shipping;
      case 'commande':
      case 'order':
        return Icons.shopping_cart;
      case 'payment':
      case 'paiement':
        return Icons.payment;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
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
          title: Row(
            children: [
              const Text('Notifications', style: TextStyle(fontSize: 18)),
              if (_isInitializing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_isPushEnabled)
                const Icon(
                  Icons.notifications_active,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.grey),
              onPressed: _refreshNotifications,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: _onMenuSelected,
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'mark_all', child: Text('Tout marquer lu')),
                const PopupMenuItem(value: 'clear_all', child: Text('Effacer tout')),
                PopupMenuItem(
                  value: 'toggle_push',
                  child: Row(
                    children: [
                      Icon(
                        _isPushEnabled
                            ? Icons.notifications_off
                            : Icons.notifications_active,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(_isPushEnabled
                          ? 'Désactiver push'
                          : 'Activer push'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                    value: 'settings', child: Text('Paramètres')),
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
            RefreshIndicator(
              onRefresh: () async => _refreshNotifications(),
              child: FutureBuilder<List<NotificationModel>>(
                future: _futureNotifications,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Erreur : ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshNotifications,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Aucune notification',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (_, i) => _buildNotificationItem(list[i]),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: list.length,
                  );
                },
              ),
            ),
            const Center(
              child: Text('Aucun message'),
            ),
          ],
        ),
      ),
    );
  }
}
