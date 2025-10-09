import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/MessagePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/notification_livraison_page.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/discussionPage.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({super.key, this.onChanged});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final UserService _userService = UserService();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    await _userService.ensureUserLoaded();
    setState(() {
      _currentUserId = _userService.userId ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 🔍 Barre de recherche
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: widget.onChanged,
                    decoration: const InputDecoration(
                      hintText: 'Recherchez selon vos besoins...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ⚙️ Bouton filtre
        GestureDetector(
          onTap: () {
            // Logic for filtering
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.grey),
          ),
        ),

        const SizedBox(width: 8),

        // 💬 Messages avec badge (NOUVEAU)
        GestureDetector(
          onTap: () {
            // Naviguer vers la page de la liste des messages
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MessagesPage(currentUserId: _currentUserId),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.blue, 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      height: 6,
                      width: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // 🔔 Notification cliquable avec badge
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationLivraisonPage(),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_none, color: Colors.white),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      height: 6,
                      width: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}