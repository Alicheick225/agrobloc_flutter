import 'package:agrobloc/core/features/Agrobloc/data/models/commande_vente.dart';
import 'package:agrobloc/core/utils/api_token.dart';

class CommandeVenteService {
  static String get baseUrl => '${ApiConfig.apiBaseUrl}/commandes';

  Future<List<CommandeVente>> getAllCommandes() async {
    // DEMO : renvoie 2 commandes avec colonnes exactes
    await Future.delayed(const Duration(seconds: 1));
    return [
      CommandeVente(
        id: 'cmd-1',
        annoncesVenteId: 'vente-abc',
        acheteurId: 'user-123',
        quantite: 10,
        prixTotal: 63520,
        modePaiementId: 'mp-1',
        statut: CommandeStatus.termine,
        createdAt: DateTime.now(),
      ),
      CommandeVente(
        id: 'cmd-2',
        annoncesVenteId: 'vente-def',
        acheteurId: 'user-456',
        quantite: 5,
        prixTotal: 30000,
        modePaiementId: 'mp-2',
        statut: CommandeStatus.enCours,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<CommandeVente> getCommandeById(String id) async {
    final list = await getAllCommandes();
    return list.firstWhere((c) => c.id == id);
  }
}