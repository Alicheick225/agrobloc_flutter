class RecommendationModel {
  final String image;
  final String name;
  final String quantity;
  final String location;
  final String price;       // ex: "1700 FCFA / kg"
  final String timeAgo;     // ex: "il y a 2 jours"
  final String status;      // ex: "Disponible" or "Prévisionnel"


  RecommendationModel( {
    required this.image,
    required this.name,
    required this.quantity,
    required this.location,
    required this.price,
    required this.timeAgo,
    required this.status,
  });
}
