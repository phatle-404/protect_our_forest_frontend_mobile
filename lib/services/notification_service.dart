import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:protect_our_forest/models/notification.dart';

class NotificationService {
  static final client = http.Client();
  static final storage = FlutterSecureStorage();

  // Tạo thông báo mới
  static Future<void> createNotification(NotificationModels notification) async {
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/notifications/create'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
      body: jsonEncode(notification.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }

  // Lấy tất cả thông báo
  static Future<List<NotificationModels>> loadAllNotifications() async {
    final response = await client.get(
      Uri.parse('http://10.0.2.2:8000/notifications/by-user'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
    );
    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => NotificationModels.fromJson(json)).toList();
  }

  static Future<List<NotificationModels>> markNotificationsAsRead(String notificationId) async {
    final response = await client.patch(
      Uri.parse('http://10.0.2.2:8000/notifications/mark-as-read'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
      body: jsonEncode({'notificationId': notificationId}),
    );
    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => NotificationModels.fromJson(json)).toList();
  }

  static Future<void> deleteNotification(String notificationId) async {
    final response = await client.delete(
      Uri.parse('http://10.0.2.2:8000/notifications/delete?notificationId=$notificationId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
    );
    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }
}
