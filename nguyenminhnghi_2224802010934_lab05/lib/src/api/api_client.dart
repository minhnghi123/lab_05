import "dart:convert";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "../models/todo_item.dart";

class AuthSession {
  const AuthSession({required this.token, required this.userId});

  final String token;
  final String userId;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000";
    }
    return "http://10.0.2.2:3000";
  }

  static const Map<String, String> _jsonHeaders = {
    "Content-Type": "application/json",
  };

  Future<void> register(String email, String password) async {
    final response = await _client.post(
      Uri.parse("$baseUrl/register"),
      headers: _jsonHeaders,
      body: jsonEncode({"email": email, "password": password}),
    );
    final data = _decodeJson(response);
    _throwIfError(response, data);
  }

  Future<AuthSession> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse("$baseUrl/login"),
      headers: _jsonHeaders,
      body: jsonEncode({"email": email, "password": password}),
    );
    final data = _decodeJson(response);
    _throwIfError(response, data);
    final token = data["token"]?.toString() ?? "";
    if (token.isEmpty) {
      throw Exception("Login failed: missing token");
    }
    final userId = _extractUserIdFromToken(token);
    return AuthSession(token: token, userId: userId);
  }

  Future<List<TodoItem>> getTodos(String userId) async {
    final response = await _client.get(
      Uri.parse("$baseUrl/getUserTodoList?userId=$userId"),
    );
    final data = _decodeJson(response);
    _throwIfError(response, data);
    final rawItems = data["success"];
    if (rawItems is! List) {
      return [];
    }
    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(TodoItem.fromJson)
        .toList();
  }

  Future<TodoItem> createTodo(
    String userId,
    String title,
    String description,
  ) async {
    final response = await _client.post(
      Uri.parse("$baseUrl/createToDo"),
      headers: _jsonHeaders,
      body: jsonEncode({"userId": userId, "title": title, "desc": description}),
    );
    final data = _decodeJson(response);
    _throwIfError(response, data);
    final rawItem = data["success"];
    if (rawItem is! Map<String, dynamic>) {
      throw Exception("Create failed: unexpected response");
    }
    return TodoItem.fromJson(rawItem);
  }

  Future<TodoItem> updateTodo(
    String id,
    String title,
    String description,
  ) async {
    final response = await _client.put(
      Uri.parse("$baseUrl/updateTodo"),
      headers: _jsonHeaders,
      body: jsonEncode({"id": id, "title": title, "desc": description}),
    );
    final data = _decodeJson(response);
    _throwIfError(response, data);
    final rawItem = data["success"];
    if (rawItem is! Map<String, dynamic>) {
      throw Exception("Update failed: unexpected response");
    }
    return TodoItem.fromJson(rawItem);
  }

  Future<void> deleteTodo(String id) async {
    final response = await _client.post(
      Uri.parse("$baseUrl/deleteTodo"),
      headers: _jsonHeaders,
      body: jsonEncode({"id": id}),
    );
    final data = _decodeJson(response);
    _throwIfError(response, data);
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {"data": decoded};
  }

  void _throwIfError(http.Response response, Map<String, dynamic> data) {
    if (response.statusCode >= 400) {
      throw Exception(_messageFrom(data) ?? "Request failed");
    }
    if (data["status"] == false) {
      throw Exception(_messageFrom(data) ?? "Request failed");
    }
  }

  String? _messageFrom(Map<String, dynamic> data) {
    return data["message"]?.toString() ?? data["error"]?.toString();
  }

  String _extractUserIdFromToken(String token) {
    final parts = token.split(".");
    if (parts.length < 2) {
      throw Exception("Invalid token");
    }
    final payload = _decodeBase64Url(parts[1]);
    final payloadJson = jsonDecode(payload);
    if (payloadJson is! Map<String, dynamic>) {
      throw Exception("Invalid token payload");
    }
    final userId = payloadJson["_id"]?.toString() ?? "";
    if (userId.isEmpty) {
      throw Exception("Token missing user id");
    }
    return userId;
  }

  String _decodeBase64Url(String input) {
    final normalized = base64.normalize(input);
    return utf8.decode(base64Url.decode(normalized));
  }
}
