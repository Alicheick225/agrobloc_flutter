import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/notificationModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NotificationService {
  static const String _baseUrl = 'http://192.168.252.170:8080/api';

  Future<List<NotificationModel>> fetchNotifications() async {
    final uri = Uri.parse('$_baseUrl/notifications');
    final response = await http.get(uri);

    if (kDebugMode) {
      debugPrint(' Response body: ${response.body}');
    }

    if (response.statusCode != 200) {
      throw Exception('Échec du chargement (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    final notifications = data.map((item) {
      if (kDebugMode) debugPrint('raw item: $item');
      return NotificationModel.fromJson(item as Map<String, dynamic>);
    }).toList();

    // TRIER les notifications les plus récentes en premier
    notifications.sort((a, b) => b.date.compareTo(a.date));

    return notifications;
  }
}
