class NotificationModel {
  final String message;
  final DateTime date;

  NotificationModel({
    required this.message,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawMessage = json['message'] as String?;
    final message = rawMessage?.trim().isNotEmpty == true ? rawMessage! : '—';

    final rawDate = json['created_at'] as String?;
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    return NotificationModel(
      message: message,
      date: parsedDate,
    );
  }
}
