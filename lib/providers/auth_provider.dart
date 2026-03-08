
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/User.dart';

import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Future<void> init() async {
    _currentUser = await StorageService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {

    _isLoading = true;
    _error = null;
    notifyListeners();

    final users = await StorageService.getUsers();

    try {
      final user = users.firstWhere(
            (u) => u.email == email && u.password == password,
      );

      _currentUser = user;
      await StorageService.setCurrentUser(user);

      _isLoading = false;
      notifyListeners();

      return true;

    } catch (e) {

      _error = "Email ou mot de passe incorrect";

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {

    _isLoading = true;
    notifyListeners();

    final users = await StorageService.getUsers();

    if (users.any((u) => u.email == email)) {

      _error = "Email déjà utilisé";
      _isLoading = false;
      notifyListeners();

      return false;
    }

    final newUser = User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
    );

    users.add(newUser);

    await StorageService.saveUsers(users);
    await StorageService.setCurrentUser(newUser);

    _currentUser = newUser;

    _isLoading = false;

    notifyListeners();

    return true;
  }

  Future<void> logout() async {

    _currentUser = null;

    await StorageService.clearCurrentUser();

    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? email}) async {

    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    final users = await StorageService.getUsers();

    // mettre à jour l'utilisateur courant
    final updatedUser = _currentUser!.copyWith(
      name: name,
      email: email,
    );

    // remplacer l'utilisateur dans la liste
    final index = users.indexWhere((u) => u.id == _currentUser!.id);

    if (index != -1) {
      users[index] = updatedUser;
    }

    // sauvegarder
    await StorageService.saveUsers(users);
    await StorageService.setCurrentUser(updatedUser);

    _currentUser = updatedUser;

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
