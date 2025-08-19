import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:protect_our_forest/models/request.dart';

class RequestService {
  // This class handles generic HTTP requests.
  // It can include methods for GET, POST, PUT, DELETE, etc.
  final client = http.Client();
  final storage = FlutterSecureStorage();

  Future<void> createRequest(Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse("http://10.0.2.2:8000/requests/create-request"),
      headers: {
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }
}
