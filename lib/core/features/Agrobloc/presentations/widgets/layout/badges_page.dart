import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/BadgeService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/BadgeModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  final BadgeService _badgeService = BadgeService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  List<BadgeModel> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);
    try {
      final user = _userService.currentUser;
      if (user != null) {
        _badges = await _badgeService.getBadgesForUser(user.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des badges: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadBadge() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un badge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom du badge'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optionnel)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        final user = _userService.currentUser;
        if (user != null) {
          await _badgeService.uploadBadge(
            userId: user.id,
            imageFile: File(pickedFile.path),
            name: nameController.text,
            description: descriptionController.text.isEmpty ? null : descriptionController.text,
          );
          _loadBadges();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Badge ajouté avec succès')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du badge: $e')),
        );
      }
    }
  }

  Future<void> _deleteBadge(BadgeModel badge) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le badge'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce badge ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _badgeService.deleteBadge(badge.id);
        _loadBadges();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Badge supprimé avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes badges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _uploadBadge,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _badges.isEmpty
              ? const Center(
                  child: Text('Aucun badge trouvé. Ajoutez-en un !'),
                )
              : ListView.builder(
                  itemCount: _badges.length,
                  itemBuilder: (context, index) {
                    final badge = _badges[index];
                    return ListTile(
                      leading: Image.network(
                        badge.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                      title: Text(badge.name),
                      subtitle: badge.description != null ? Text(badge.description!) : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteBadge(badge),
                      ),
                    );
                  },
                ),
    );
  }
}
