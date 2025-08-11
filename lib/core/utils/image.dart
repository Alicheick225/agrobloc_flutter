String getImageUrl(String? photo) {
  if (photo == null || photo.isEmpty) return "";
  if (photo.startsWith("http")) return photo;

  // ✅ Base URL (change en fonction de ton environnement)
  //const baseUrl = "http://10.0.2.2:8080"; // ✅ pour Android Emulator
   const baseUrl = "http://192.168.252.199:8080"; // ✅ pour un vrai téléphone

  // ✅ Ajoute un "/" si manquant
  final normalizedPhoto = photo.startsWith("/") ? photo : "/$photo";
  final url = "$baseUrl$normalizedPhoto";

  print("🔗 IMAGE URL: $url"); // ✅ Debug

  return url;
}
