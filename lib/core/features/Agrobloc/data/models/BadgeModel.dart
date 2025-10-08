class BadgeModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String imageUrl;
  final DateTime createdAt;

  BadgeModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
