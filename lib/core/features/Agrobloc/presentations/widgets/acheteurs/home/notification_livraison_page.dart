import 'package:agrobloc/core/features/Agrobloc/data/dataSources/notificationService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/notificationModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    extends State<NotificationLivraisonPage> with TickerProviderStateMixin {
  final NotificationService _service = NotificationService();
  late Future<List<NotificationModel>> _futureNotifications;
  late AnimationController _refreshController;

  bool _isPushEnabled = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _futureNotifications = _loadSortedNotifications();
    _initializePushNotifications();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
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
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications, 
                      color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nouvelle notification: ${notification.title}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 4),
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
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
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
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
          _showMessage('Toutes les notifications marquées comme lues', Icons.done_all);
        }
        break;
      case 'clear_all':
        _showMessage('Fonction à implémenter', Icons.info);
        break;
      case 'settings':
        _showMessage('Paramètres à implémenter', Icons.settings);
        break;
      case 'toggle_push':
        await _togglePushNotifications();
        break;
    }
  }

  Future<void> _togglePushNotifications() async {
    if (widget.userId == null) {
      _showMessage('ID utilisateur requis pour les notifications push', Icons.warning);
      return;
    }

    if (_isPushEnabled) {
      _service.stopListening();
      setState(() => _isPushEnabled = false);
      _showMessage('Notifications push désactivées', Icons.notifications_off);
    } else {
      final registered = await _service.registerDeviceToken(widget.userId!);
      if (registered) {
        await _service.startListening(userId: widget.userId);
        setState(() => _isPushEnabled = true);
        _showMessage('Notifications push activées', Icons.notifications_active);
      } else {
        _showMessage('Erreur lors de l\'activation', Icons.error);
      }
    }
  }

  void _showMessage(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'nouvelle_commande':
      case 'new_order':
        return const Color(0xFF4CAF50); // Vert pour nouvelles commandes
      case 'nouvelle_page':
        return const Color(0xFF2196F3); // Bleu pour nouvelles pages
      case 'nouvelle_image':
        return const Color(0xFFFF9800); // Orange pour nouvelles images
      case 'commande_validee':
        return const Color(0xFF9C27B0); // Violet pour commandes validées
      case 'livraison':
      case 'delivery':
        return const Color(0xFF00BCD4); // Cyan pour livraisons
      case 'payment':
      case 'paiement':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'nouvelle_commande':
      case 'new_order':
        return 'NEW_ORDER';
      case 'nouvelle_page':
        return 'NOUVELLE_COMMANDE';
      case 'nouvelle_image':
        return 'NOUVELLE_COMMANDE';
      case 'commande_validee':
        return 'ORDER_CONFIRMED';
      case 'livraison':
      case 'delivery':
        return 'DELIVERY';
      default:
        return type.toUpperCase();
    }
  }

  Widget _buildNotificationItem(NotificationModel notif, int index) {
    final typeColor = _getTypeColor(notif.type);
    final typeLabel = _getTypeLabel(notif.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          if (!notif.isRead && widget.userId != null) {
            await _service.markAsRead(notif.id);
            _refreshNotifications();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône de notification (cloche dorée)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications,
                color: Color(0xFFFFB300), // Couleur dorée comme dans l'image
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Contenu de la notification
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                      ),
                      // Point vert pour notifications non lues
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4, left: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        _formatRelative(notif.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fond gris très clair
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bouton refresh
          RotationTransition(
            turns: _refreshController,
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF666666),
                size: 24,
              ),
              onPressed: _refreshNotifications,
            ),
          ),
          // Menu 3 points
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF666666),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: _onMenuSelected,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'mark_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Tout marquer lu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Effacer tout'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_push',
                child: Row(
                  children: [
                    Icon(
                      _isPushEnabled
                          ? Icons.notifications_off_rounded
                          : Icons.notifications_active_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(_isPushEnabled
                        ? 'Désactiver push'
                        : 'Activer push'),
                  ],
                ),
              ),
            ],
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshNotifications(),
        color: AppColors.primaryGreen,
        backgroundColor: Colors.white,
        child: FutureBuilder<List<NotificationModel>>(
          future: _futureNotifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Erreur de chargement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _refreshNotifications,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Aucune notification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous êtes à jour !',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // Liste des notifications avec le design exact de l'image
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) => _buildNotificationItem(list[i], i),
              itemCount: list.length,
            );
          },
        ),
      ),
    );
  }
}