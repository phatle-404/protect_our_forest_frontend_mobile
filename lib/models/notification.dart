class NotificationModels {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final DateTime createAt;
  final bool isRead;

  NotificationModels({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.createAt,
    this.isRead = false,
  });

  factory NotificationModels.fromJson(Map<String, dynamic> json) {
    String createdAtStr = '';
    if (json['timestamp'] is Map && json['timestamp']?['createdAt'] != null) {
      createdAtStr = json['timestamp']['createdAt'].toString();
    } else if (json['createdAt'] != null) {
      createdAtStr = json['createdAt'].toString();
    }

    return NotificationModels(
      notificationId: json['notificationId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createAt: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'createAt': createAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
