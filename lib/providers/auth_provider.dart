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

  /// Initialisation pour récupérer l'utilisateur courant
  Future<void> init() async {
    _currentUser = await StorageService.getCurrentUser();
    notifyListeners();
  }

  /// LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final users = await StorageService.getUsers();



    try {
      final user = users.firstWhere(
            (u) =>
        u.email.toLowerCase().trim() == email.toLowerCase().trim() &&
            u.password.trim() == password.trim(),
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

  /// REGISTER
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // 1. Récupérer tous les utilisateurs existants
    final users = await StorageService.getUsers();

    // 2. Vérifier si l'email existe déjà
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      _error = "Email déjà utilisé";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 3. Créer le nouvel utilisateur
    final newUser = User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
    );

    // 4. Ajouter le nouvel utilisateur à la liste existante
    users.add(newUser);

    // 5. Sauvegarder tous les utilisateurs
    await StorageService.saveUsers(users);
    await StorageService.setCurrentUser(newUser);

    _currentUser = newUser;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// LOGOUT
  Future<void> logout() async {
    _currentUser = null;
    await StorageService.clearCurrentUser();
    notifyListeners();
  }

  /// Mettre à jour le profil utilisateur
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    final users = await StorageService.getUsers();

    final updatedUser = _currentUser!.copyWith(
      name: name,
      email: email,
    );

    final index = users.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      users[index] = updatedUser;
    }

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

  Future<void> printUsers() async {
    final users = await StorageService.getUsers();
    if (users.isEmpty) {
      print("Aucun utilisateur enregistré.");
    } else {
      print("Liste des utilisateurs :");
      for (var u in users) {
        print(
            "ID: ${u.id}, Name: ${u.name}, Email: ${u.email}, Password: ${u.password}, Avatar: ${u.avatar}, CreatedAt: ${u.createdAt}"
        );
      }
    }
  }
}