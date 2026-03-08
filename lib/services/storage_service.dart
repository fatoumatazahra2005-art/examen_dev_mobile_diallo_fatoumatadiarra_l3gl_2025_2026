import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';
import 'dart:convert';

/**
 * Pattern Singleton:
 * Pour avoir une seule instance
 */
class StorageService {
  //===== Singleton ==========
  /// Instance Unique (privee)
  static StorageService? _instance;

  /// Getter pour acceder a l'instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Constructeur prive
  StorageService._();

  //===== SharedPreferences ==========
  /**
   * SharedPreferences utilise des opérations asynchrones
   * car il lit/ecrtit sur le disque
   *
   * Le mot-cle await attend que l'operation se termine
   * La fonction doit etre marque async et retourner un Future
   * Les variables doivent être marqué par late
   */
  late SharedPreferences _prefs;

  /// Indicateur d'initialisation
  bool _initialized = false;

  Future<void> init() async {
    if(_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Cles de Stockage =========
  static const String _keyOnboardingComplete = 'onboarding_complete';


  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  Future<void> setOnboardingStatus(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }


  Future<bool> getOnboardingStatus() async {
    if (!_initialized) await init(); // assure que SharedPreferences est prêt
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  //////////////////////////////USERS//////////////////////////////////////


  static const String usersKey = "users";
  static const String currentUserKey = "current_user";

  static Future<void> saveUsers(List<User> users) async {

    final prefs = await SharedPreferences.getInstance();

    final usersMap = users.map((user) => user.toMap()).toList();

    await prefs.setString(
      usersKey,
      jsonEncode(usersMap),
    );
  }

  static Future<List<User>> getUsers() async {

    final prefs = await SharedPreferences.getInstance();

    final usersString = prefs.getString(usersKey);

    if (usersString == null) return [];

    final List decoded = jsonDecode(usersString);

    return decoded.map((map) => User.fromMap(map)).toList();
  }

  static Future<void> setCurrentUser(User user) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      currentUserKey,
      jsonEncode(user.toMap()),
    );
  }

  static Future<User?> getCurrentUser() async {

    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString(currentUserKey);

    if (userString == null) return null;

    return User.fromMap(
      jsonDecode(userString),
    );
  }

  static Future<void> clearCurrentUser() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(currentUserKey);
  }

}