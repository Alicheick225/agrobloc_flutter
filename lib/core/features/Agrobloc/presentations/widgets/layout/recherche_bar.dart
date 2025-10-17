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
      ],
    );
  }
}