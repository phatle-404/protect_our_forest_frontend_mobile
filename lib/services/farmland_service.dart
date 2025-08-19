import 'dart:convert';
import 'package:protect_our_forest/models/farmland.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FarmlandDataService {
  static final client = http.Client();
  static final storage = FlutterSecureStorage();

  static Future<String> createFarmlandAsPending(Farmland farmland) async {
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/farmlands/create-farmland'),
      headers: {
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        ...farmland.toJson(),
        'userId': await storage.read(key: 'userId'),
      }),
    );

    if (response.statusCode != 201) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['farmland']['farmlandId'];
  }

  static Future<List<Farmland>> getFarmlandByUser(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    final response = await client.get(
      Uri.parse(
        'http://10.0.2.2:8000/farmlands/get-farmland-by-user?userId=$userId',
      ),
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
    return data.map((json) => Farmland.fromJson(json)).toList();
  }

  static Future<Farmland> getFarmlandById(String farmlandId) async {
    final response = await client.get(
      Uri.parse(
        'http://10.0.2.2:8000/farmlands/get-farmland-by-id?farmlandId=$farmlandId',
      ),
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
    return Farmland.fromJson(data['farmland']);
  }

  static Future<List<Farmland>> getFarmlandByAddress(
    String province,
    String district,
  ) async {
    if (province.isEmpty && district.isEmpty) {
      throw Exception('Address không được để trống');
    }

    final response = await client.get(
      Uri.parse(
        'http://10.0.2.2:8000/farmlands/get-farmland-by-address?province=$province&district=$district',
      ),
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
    return (data['farmlands'] as List)
        .map((json) => Farmland.fromJson(json))
        .toList();
  }

  static Future<Farmland> updateFarmland(
    String farmlandId,
    Farmland farmland,
  ) async {
    final response = await client.put(
      Uri.parse(
        'http://10.0.2.2:8000/farmlands/update-farmland?farmlandId=$farmlandId',
      ),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
      body: jsonEncode({
        ...farmland.toJson(),
        'userId': await storage.read(key: 'userId'),
      }),
    );

    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return Farmland.fromJson(data);
  }

  static Future<Farmland> deleteFarmland(String farmlandId) async {
    final response = await client.delete(
      Uri.parse(
        'http://10.0.2.2:8000/farmlands/delete-farmland?farmlandId=$farmlandId',
      ),
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
    return Farmland.fromJson(data);
  }
}
