import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:protect_our_forest/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // This class handles authentication-related operations.
  // It can include methods for login, logout, registration, etc.
  final client = http.Client();
  final storage = FlutterSecureStorage();

  Future<User> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/auth/users/login'), // Giả sử endpoint là /auth/login
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      await storage.write(key: 'accessToken', value: jsonDecode(response.body)['accessToken']);
      await storage.write(key: 'refreshToken', value: jsonDecode(response.body)['refreshToken']);
      await storage.write(key: 'userId', value: jsonDecode(response.body)['user']['userId']);
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }

  Future<void> register(String userName, String email, String password, String district, String province) async {
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/auth/users/register'), // Giả sử endpoint là /auth/register
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userName': userName,
        'email': email,
        'password': password,
        'address': {
          'district': district,
          'province': province,
        },
      }),
    );

    if (response.statusCode != 201) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    // Implement logout logic 
    final refreshToken = await storage.read(key: 'refreshToken');

    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/auth/users/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
      body: jsonEncode({"refreshToken": refreshToken}),
    );
    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }

  Future<void> requestOTP(String email) async {
    // Implement registration logic here
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/auth/users/request-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }

  Future<void> verifyOTP(String otp, String email) async {
    // Implement OTP verification logic here
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/auth/users/verify-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'otp': otp,
      }),
    );
    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }

  Future<void> requestAccessToken() async {
    // Implement access token request logic here
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/auth/users/access-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'refreshToken')}',
      },
    );
    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    }
  }

  Future<void> requestRefreshToken() async {
    // Implement access token refresh logic here
    final response = await client.post(
      Uri.parse('http://10.0.2.2:8000/auth/users/refresh-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await storage.read(key: 'refreshToken')}',
      },
    );
    if (response.statusCode != 200) {
      final message = jsonDecode(response.body)['message'];
      throw Exception(message);
    } 
  }
}
