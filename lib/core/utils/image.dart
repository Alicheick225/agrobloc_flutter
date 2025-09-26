import 'package:agrobloc/core/features/Agrobloc/data/dataSources/supabaseService.dart';

final _imageService = SupabaseImageService();

String getImageUrl(String? fileName) {
  if (fileName == null || fileName.isEmpty) {
    return "https://via.placeholder.com/150";
  }

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
