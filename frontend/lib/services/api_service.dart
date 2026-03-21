import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  final _storage = const FlutterSecureStorage();
  String? _token;

  Future<void> loadToken() async {
    _token = await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: AppConstants.tokenKey);
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('${AppConstants.baseUrl}$path');

  Future<Map<String, dynamic>> register({required String name, required String email, required String password}) async {
    try {
      final res = await http.post(_uri('/api/auth/register'),
          headers: _headers, body: jsonEncode({'name': name, 'email': email, 'password': password}));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) { await saveToken(body['token']); return {'success': true, 'user': body['user']}; }
      return {'success': false, 'error': body['error'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'error': 'Cannot connect to server. Is the backend running?'};
    }
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final res = await http.post(_uri('/api/auth/login'),
          headers: _headers, body: jsonEncode({'email': email, 'password': password}));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) { await saveToken(body['token']); return {'success': true, 'user': body['user']}; }
      return {'success': false, 'error': body['error'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': 'Cannot connect to server. Is the backend running?'};
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await http.get(_uri('/api/auth/me'), headers: _headers);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'user': body['user']};
      return {'success': false, 'error': body['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({required String name}) async {
    try {
      final res = await http.put(_uri('/api/auth/profile'),
          headers: _headers, body: jsonEncode({'name': name}));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'user': body['user']};
      return {'success': false, 'error': body['error'] ?? 'Update failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> getTasks() async {
    try {
      final res = await http.get(_uri('/api/tasks'), headers: _headers);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'tasks': body['tasks']};
      return {'success': false, 'error': body['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    try {
      final res = await http.post(_uri('/api/tasks'), headers: _headers, body: jsonEncode(data));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) return {'success': true, 'task': body['task']};
      return {'success': false, 'error': body['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(_uri('/api/tasks/$id'), headers: _headers, body: jsonEncode(data));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'task': body['task']};
      return {'success': false, 'error': body['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error'};
    }
  }

  Future<bool> toggleTask(String id) async {
    try {
      final res = await http.patch(_uri('/api/tasks/$id/toggle'), headers: _headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      final res = await http.delete(_uri('/api/tasks/$id'), headers: _headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getNotes() async {
    try {
      final res = await http.get(_uri('/api/notes'), headers: _headers);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'notes': body['notes']};
      return {'success': false, 'error': body['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> createNote(Map<String, dynamic> data) async {
    try {
      final res = await http.post(_uri('/api/notes'), headers: _headers, body: jsonEncode(data));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) return {'success': true, 'note': body['note']};
      return {'success': false, 'error': body['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error'};
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      final res = await http.delete(_uri('/api/notes/$id'), headers: _headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
