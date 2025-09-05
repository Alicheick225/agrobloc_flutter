import 'package:agrobloc/core/utils/api_token.dart';

String getImageUrl(String? photo) {
  if (photo == null || photo.isEmpty) return "";
  if (photo.startsWith("http")) return photo;

  // ✅ Base URL (change en fonction de ton environnement)
  //const baseUrl = "http://10.0.2.2:8080"; // ✅ pour Android Emulator
  final baseUrl = ApiConfig.imageBaseUrl; // ✅ pour un vrai téléphone - now configurable

  // ✅ Ajoute un "/" si manquant
  final normalizedPhoto = photo.startsWith("/") ? photo : "/$photo";
  final url = "$baseUrl$normalizedPhoto";

  print("🔗 IMAGE URL: $url"); // ✅ Debug

  return url;
}
