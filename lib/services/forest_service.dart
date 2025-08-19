import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/forest.dart';
import 'package:http/http.dart' as http;

class ForestDataService {
  static final client = http.Client();
  static final storage = FlutterSecureStorage();

  //Lấy dữ liệu rừng từ API
  static Future<List<Forest>> loadAllForestData() async {
    final response = await client.get(
      Uri.parse(
        'http://10.0.2.2:8000/forests/get-all-forests',
      ), // nhớ đúng route
      headers: {
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
    );

    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Forest.fromJson(json)).toList();
  }

  //Lấy dữ liệu rừng theo địa chỉ
  static Future<List<Forest>> loadForestDataByAddress(String province) async {
    final response = await client.get(
      Uri.parse(
        'http://10.0.2.2:8000/forests/get-forests-by-address?province=$province',
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

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Forest.fromJson(json)).toList();
  }
}
