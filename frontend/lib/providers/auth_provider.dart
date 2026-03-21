import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _initialized = false;
  final ApiService _api = ApiService();

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    await _api.loadToken();
    if (_api.hasToken) {
      final result = await _api.getMe();
      if (result['success'] == true) {
        _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      } else {
        await _api.clearToken();
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<String?> register({required String name, required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.register(name: name, email: email, password: password);
    if (result['success'] == true) {
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      _isLoading = false;
      notifyListeners();
      return null;
    }
    _isLoading = false;
    notifyListeners();
    return result['error'] as String;
  }

  Future<String?> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.login(email: email, password: password);
    if (result['success'] == true) {
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      _isLoading = false;
      notifyListeners();
      return null;
    }
    _isLoading = false;
    notifyListeners();
    return result['error'] as String;
  }

  Future<void> updateProfile({required String name}) async {
    final result = await _api.updateProfile(name: name);
    if (result['success'] == true) {
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    _user = null;
    notifyListeners();
  }
}
