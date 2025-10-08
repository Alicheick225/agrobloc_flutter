import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseImageService {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = "agrobloc"; // 👉 Ton bucket Supabase
  final _uuid = const Uuid();

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  /// 📤 Upload une image
  Future<String?> uploadImage(Uint8List fileBytes, String originalName) async {
    try {
      // Génère un nom unique (UUID + extension)
      final ext = originalName.split('.').last.toLowerCase();
      final uniqueName = "uploads/${_uuid.v4()}.$ext";
      final contentType = _getContentType(ext);

      final response = await supabase.storage
          .from(bucketName)
          .uploadBinary(uniqueName, fileBytes,
              fileOptions: FileOptions(upsert: true, contentType: contentType));

      // On success, response is the path; on failure, throws exception
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(response);
      print("✅ Upload réussi: $publicUrl");
      return publicUrl;
    } catch (e) {
      print("❌ Upload échoué: $e");
      return null;
    }
  }

  /// 📥 Liste toutes les images du dossier uploads/
  Future<List<String>> listImages() async {
    try {
      final response =
          await supabase.storage.from(bucketName).list(path: "uploads");

      return response.map((file) {
        return supabase.storage.from(bucketName).getPublicUrl("uploads/${file.name}");
      }).toList();
    } catch (e) {
      print("❌ Erreur listImages: $e");
      return [];
    }
  }

  /// 🗑 Supprimer une image par son nom
  Future<void> deleteImage(String fileName) async {
    try {
      await supabase.storage.from(bucketName).remove(["uploads/$fileName"]);
      print("🗑 Image supprimée: uploads/$fileName");
    } catch (e) {
      print("❌ Erreur deleteImage: $e");
    }
  }
}
