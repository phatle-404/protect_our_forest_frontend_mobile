import 'dart:convert';
import 'package:protect_our_forest/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserDataService {
  static final client = http.Client();
  static final storage = FlutterSecureStorage();

  static Future<User> loadUserData() async {
    String? userId = await storage.read(key: 'userId');
    final response = await client.get(
      Uri.parse(
        'http://10.0.2.2:8000/users/get-by-id?userId=$userId',
      ), // nhớ đúng route
      headers: {
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['user'] == null) {
      throw Exception("Server không trả về dữ liệu người dùng");
    }

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  static Future<void> updateUserData(User user) async {
    final response = await client.put(
      Uri.parse(
        'http://10.0.2.2:8000/users/update-by-id?userId=${user.userId}',
      ),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }

  static Future<User> loadAllUserByAddress(
    String district,
    String province,
  ) async {
    final response = await client.get(
      Uri.parse(
        'http://10.0.2.2:8000/users/get-by-id?district=$district&province=$province',
      ), // nhớ đúng route
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
    );

    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return User.fromJson(data['user']);
  }
}
