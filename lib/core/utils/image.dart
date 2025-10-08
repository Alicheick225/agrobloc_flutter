import 'package:agrobloc/core/features/Agrobloc/data/dataSources/supabaseService.dart';

final _imageService = SupabaseImageService();

String getImageUrl(String? fileName) {
  if (fileName == null || fileName.isEmpty) {
    return "https://via.placeholder.com/150";
  }

  if (fileName.startsWith("http")) {
    // C'est une URL complète, nettoyer les erreurs communes
    // Nettoyer plusieurs slashs consécutifs après https:
    String cleanedUrl = fileName.replaceAll(RegExp(r'https:/+'), 'https://');
    print("🔗 IMAGE URL (Full URL Cleaned): $cleanedUrl");
    return cleanedUrl;
  } else {
    // C'est un nom de fichier, construire l'URL
    // 🔥 Nettoyer les doublons de slash
    String cleanFileName = fileName.replaceAll("//", "/");

    // 🔥 Supprimer "/" au tout début
    if (cleanFileName.startsWith("/")) {
      cleanFileName = cleanFileName.substring(1);
    }

    final url = _imageService.supabase
        .storage
        .from(_imageService.bucketName)
        .getPublicUrl(cleanFileName);

    print("🔗 IMAGE URL (Supabase Cleaned): $url");
    return url;
  }
}
