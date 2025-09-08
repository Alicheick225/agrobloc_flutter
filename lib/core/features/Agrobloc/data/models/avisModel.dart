class AvisAchat {
  final String id;
  final double note;
  final String? titre;
  final String? commentaire;
  final String noteurId;
  final String annoncesAchatId;
  final String? nomNoteur;
  final String? photoAnnonce;
  final String? nomProduit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AvisAchat({
    required this.id,
    required this.note,
    this.titre,
    this.commentaire,
    required this.noteurId,
    required this.annoncesAchatId,
    this.nomNoteur,
    this.photoAnnonce,
    this.nomProduit,
    this.createdAt,
    this.updatedAt,
  });

  // Factory pour créer depuis JSON
  factory AvisAchat.fromJson(Map<String, dynamic> json) {
    return AvisAchat(
      id: json['id'] as String,
      note: (json['note'] as num).toDouble(),
      titre: json['titre'] as String?,
      commentaire: json['commentaire'] as String?,
      noteurId: json['noteur_id'] as String,
      annoncesAchatId: json['annonces_achat_id'] as String,
      nomNoteur: json['nom_noteur'] as String?,
      photoAnnonce: json['photo_annonce'] as String?,
      nomProduit: json['nom_produit'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'titre': titre,
      'commentaire': commentaire,
      'noteur_id': noteurId,
      'annonces_achat_id': annoncesAchatId,
      'nom_noteur': nomNoteur,
      'photo_annonce': photoAnnonce,
      'nom_produit': nomProduit,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copier avec modifications
  AvisAchat copyWith({
    String? id,
    double? note,
    String? titre,
    String? commentaire,
    String? noteurId,
    String? annoncesAchatId,
    String? nomNoteur,
    String? photoAnnonce,
    String? nomProduit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvisAchat(
      id: id ?? this.id,
      note: note ?? this.note,
      titre: titre ?? this.titre,
      commentaire: commentaire ?? this.commentaire,
      noteurId: noteurId ?? this.noteurId,
      annoncesAchatId: annoncesAchatId ?? this.annoncesAchatId,
      nomNoteur: nomNoteur ?? this.nomNoteur,
      photoAnnonce: photoAnnonce ?? this.photoAnnonce,
      nomProduit: nomProduit ?? this.nomProduit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AvisAchat{id: $id, note: $note, titre: $titre, nomProduit: $nomProduit}';
  }
}

// Modèle pour créer un nouvel avis
class CreateAvisAchatRequest {
  final double note;
  final String? titre;
  final String? commentaire;
  final String annoncesAchatId;

  CreateAvisAchatRequest({
    required this.note,
    this.titre,
    this.commentaire,
    required this.annoncesAchatId,
  });

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'titre': titre,
      'commentaire': commentaire,
      'annonces_achat_id': annoncesAchatId,
    };
  }
}

// Réponse API pour la création d'avis
class AvisAchatResponse {
  final String message;
  final AvisAchat avis;

  AvisAchatResponse({
    required this.message,
    required this.avis,
  });

  factory AvisAchatResponse.fromJson(Map<String, dynamic> json) {
    return AvisAchatResponse(
      message: json['message'] as String,
      avis: AvisAchat.fromJson(json['avis'] as Map<String, dynamic>),
    );
  }
}

// Modèle pour les commandes de vente (ajouté pour la page d'évaluation)
class CommandeVente {
  final String id;
  final String? produitNom;
  final String? produitPhoto;
  final String? vendeurId;
  final String? acheteurId;
  final double? prix;
  final int? quantite;
  final String? statut;
  final DateTime? dateCommande;

  CommandeVente({
    required this.id,
    this.produitNom,
    this.produitPhoto,
    this.vendeurId,
    this.acheteurId,
    this.prix,
    this.quantite,
    this.statut,
    this.dateCommande,
  });

  factory CommandeVente.fromJson(Map<String, dynamic> json) {
    return CommandeVente(
      id: json['id'] as String,
      produitNom: json['produit_nom'] as String?,
      produitPhoto: json['produit_photo'] as String?,
      vendeurId: json['vendeur_id'] as String?,
      acheteurId: json['acheteur_id'] as String?,
      prix: json['prix']?.toDouble(),
      quantite: json['quantite'] as int?,
      statut: json['statut'] as String?,
      dateCommande: json['date_commande'] != null
          ? DateTime.parse(json['date_commande'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produit_nom': produitNom,
      'produit_photo': produitPhoto,
      'vendeur_id': vendeurId,
      'acheteur_id': acheteurId,
      'prix': prix,
      'quantite': quantite,
      'statut': statut,
      'date_commande': dateCommande?.toIso8601String(),
    };
  }
}
