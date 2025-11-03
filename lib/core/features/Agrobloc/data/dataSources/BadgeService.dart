import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/BadgeModel.dart';

class BadgeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload badge image to Supabase storage and insert into badges table
  Future<BadgeModel> uploadBadge({
    required String userId,
    required File imageFile,
    required String name,
    String? description,
  }) async {
    try {
      // Generate unique file name
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase storage
      final storageResponse = await _supabase.storage
          .from('badges') // Assuming bucket name is 'badges'
          .upload(fileName, imageFile);

      if (storageResponse.isEmpty) {
        throw Exception('Failed to upload image to storage');
      }

      // Get public URL
      final imageUrl = _supabase.storage
          .from('badges')
          .getPublicUrl(fileName);

      // Insert into badges table
      final response = await _supabase
          .from('badges')
          .insert({
            'user_id': userId,
            'name': name,
            'description': description,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return BadgeModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to upload badge: $e');
    }
  }

  // Get badges for a user
  Future<List<BadgeModel>> getBadgesForUser(String userId) async {
    try {
      final response = await _supabase
          .from('badges')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => BadgeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get badges: $e');
    }
  }

  // Delete a badge
  Future<void> deleteBadge(String badgeId) async {
    try {
      // Get badge to get image URL for deletion from storage
      final badgeResponse = await _supabase
          .from('badges')
          .select('image_url')
          .eq('id', badgeId)
          .single();

      final imageUrl = badgeResponse['image_url'] as String;

      // Extract file name from URL
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;

      // Delete from storage
      await _supabase.storage
          .from('badges')
          .remove([fileName]);

      // Delete from table
      await _supabase
          .from('badges')
          .delete()
          .eq('id', badgeId);
    } catch (e) {
      throw Exception('Failed to delete badge: $e');
    }
  }
}
