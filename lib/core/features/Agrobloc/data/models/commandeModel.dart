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
      };

  @override
  String toString() => 'CommandeModel $id - ${statut.name} (${typeCulture})';
}