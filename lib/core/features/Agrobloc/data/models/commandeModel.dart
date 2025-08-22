import 'dart:ui';
import 'package:agrobloc/core/themes/app_colors.dart';

enum CommandeStatus { enCours, termine, annule }

extension CommandeStatusExt on CommandeStatus {
  Color get color => {
        CommandeStatus.enCours: AppColors.enCours,
        CommandeStatus.termine: AppColors.termine,
        CommandeStatus.annule: AppColors.annule,
      }[this]!;
}

class CommandeModel {
  final String id;
  final String annoncesVenteId;
  final String acheteurId;
  final double quantite;
  final double prixTotal;
  final String modePaiementId;
  final CommandeStatus statut;
  final DateTime createdAt;
  final String typeCulture;
  final String nomCulture; // Libellé du type de culture depuis l'API
  final String? photoPlanteur; // Photo du planteur

  CommandeModel({
    required this.id,
    required this.annoncesVenteId,
    required this.acheteurId,
    required this.quantite,
    required this.prixTotal,
    required this.modePaiementId,
    required this.statut,
    required this.createdAt,
    required this.typeCulture,
    required this.nomCulture,
    this.photoPlanteur,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'] ?? '',
      annoncesVenteId: json['annonces_vente_id'] ?? '',
      acheteurId: json['acheteur_id'] ?? '',
      quantite: double.tryParse(json['quantite']?.toString() ?? '0') ?? 0.0,
      prixTotal: double.tryParse(json['prix_total']?.toString() ?? '0') ?? 0.0,
      modePaiementId: json['mode_paiement_id'] ?? '',
      statut: CommandeStatus.values.firstWhere(
        (e) => e.name == (json['statut'] ?? ''),
        orElse: () => CommandeStatus.enCours,
      ),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      typeCulture: json['type_culture'] ?? '',
      nomCulture: json['nom_culture']?.toString() ??
          json['type_culture']?.toString() ??
          'Culture inconnue',
      photoPlanteur: json['photo_planteur']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'annonces_vente_id': annoncesVenteId,
        'acheteur_id': acheteurId,
        'quantite': quantite,
        'prix_total': prixTotal,
        'mode_paiement_id': modePaiementId,
        'statut': statut.name,
        'created_at': createdAt.toIso8601String(),
        'type_culture': typeCulture,
        'nom_culture': nomCulture,
        'photo_planteur': photoPlanteur,
      };

// ✅ Getters pour différents formats d'affichage du nom
  String get nomCommande {
    return nomCulture;
  }

  String get nomCommandeAvecDate {
    final dateFormat = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    return '$nomCulture - $dateFormat';
  }

  String get nomCommandeCourt {
    return nomCulture.length > 20
        ? '${nomCulture.substring(0, 20)}...'
        : nomCulture;
  }

  String get nomCommandeAvecQuantite {
    return '${quantite.toStringAsFixed(1)}kg de $nomCulture';
  }

  // ✅ Getter pour l'URL complète de la photo si nécessaire
  String? get photoPlanteurUrl {
    if (photoPlanteur == null || photoPlanteur!.isEmpty) return null;

    // Si c'est déjà une URL complète
    if (photoPlanteur!.startsWith('http')) return photoPlanteur;

    // Sinon, construire l'URL complète avec votre base URL
    return 'http://192.168.252.199:3000/uploads/$photoPlanteur';
  }

  @override
  String toString() => 'CommandeModel $id - ${statut.name} ($nomCulture)';
}
