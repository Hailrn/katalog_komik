import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<UserModel?> login(String nim) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': nim, 'password': nim}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data);
      await saveToken(user.token);
      return user;
    }
    return null;
  }

  static Future<List<ProductModel>> getProducts() async {
    final url = Uri.parse('$baseUrl/api/products');
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['data']['products'];
      return products.map((p) => ProductModel.fromJson(p)).toList();
    }
    return [];
  }

  static Future<bool> addProduct({
    required String name,
    required int price,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/api/products');
    final headers = await _authHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final headers = await _authHeaders();
    final response = await http.delete(url, headers: headers);
    return response.statusCode == 200;
  }

  static Future<bool> submitTugas({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/products/submit');
    final headers = await _authHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }
}