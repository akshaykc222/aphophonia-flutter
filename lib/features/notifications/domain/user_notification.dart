class UserNotification {
  const UserNotification({
    required this.id,
    required this.titleAr,
    required this.bodyAr,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String titleAr;
  final String bodyAr;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] as String,
      titleAr: json['title_ar'] as String,
      bodyAr: json['body_ar'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }
}
