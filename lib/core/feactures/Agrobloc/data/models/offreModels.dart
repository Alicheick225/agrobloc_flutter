class OfferModel {
  final String image;
  final String location;
  final String type;
  final String product;
  final String quantity;
  final String price;
  

  OfferModel({
    required this.image,
    required this.location,
    required this.type,
    required this.product,
    required this.quantity,
    required this.price,
  });
}

class OffreModel {
  final String avatar;
  final String nom;
  final String region;
  final String culture;
  final String quantiteSouhaitee;
  final String prixUnitaire;

  OffreModel({
    required this.avatar,
    required this.nom,
    required this.region,
    required this.culture,
    required this.quantiteSouhaitee,
    required this.prixUnitaire,
  });
}
