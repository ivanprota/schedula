import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:schedula/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseAuthControllerUrl = "http://10.0.2.2:8080/auth";
  final String baseUserControllerUrl = "http://10.0.2.2:8080/api/users";

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';

  Future<User> updateUser(int id, User user) async {
    final response = await http.put(
      Uri.parse('$baseUserControllerUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Aggiornamento fallito");
    }
  }

  Future<User> getUserById(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUserControllerUrl/$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Utente non trovato");
    }
  }

  Future<User> uploadProfileImage(int userId, File imageFile) async {
    final uri = Uri.parse('$baseUserControllerUrl/$userId/profile-image');
    final request = http.MultipartRequest("POST", uri)
      ..files.add(
        await http.MultipartFile.fromPath("file", imageFile.path),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final bodyString = await response.stream.bytesToString();
      final bodyJson = jsonDecode(bodyString);
      return User.fromJson(bodyJson);
    } else {
      throw Exception(
          "Errore upload immagine (status: ${response.statusCode})");
    }
  }

  /// 🔐 LOGIN
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseAuthControllerUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['token'];
      String userId = data['userId'].toString();
      await saveToken(token);
      await saveUserId(userId);
      return token;
    } else {
      throw Exception("Credenziali non valide");
    }
  }

  /// 🆕 REGISTRAZIONE
  ///
  /// Chiama /auth/register sul backend.
  /// Il backend deve restituire un JSON con:
  /// { "token": "...", "userId": 123 }
  Future<String> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseAuthControllerUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['token'];
      String userId = data['userId'].toString();

      // Salvo token e userId come nel login
      await saveToken(token);
      await saveUserId(userId);

      return token;
    } else if (response.statusCode == 409) {
      throw Exception("Email già registrata");
    } else {
      throw Exception("Errore nella registrazione");
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }
}
