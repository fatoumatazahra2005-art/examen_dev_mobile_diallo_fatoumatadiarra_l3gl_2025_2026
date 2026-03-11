import 'package:shared_preferences/shared_preferences.dart';
import '../models/Project.dart';
import '../models/User.dart';
import '../models/Task.dart';

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

    final userStrings = users.map((u) {
      return "${u.id}|${u.name}|${u.email}|${u.password}|${u.avatar ?? ''}|${u.createdAt.millisecondsSinceEpoch}";
    }).toList();

    await prefs.setStringList(usersKey, userStrings);
  }

  // Récupérer tous les utilisateurs
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final userStrings = prefs.getStringList(usersKey);
    if (userStrings == null) return [];

    return userStrings.map((s) {
      final parts = s.split('|');
      return User(
        id: parts[0].trim(),
        name: parts[1].trim(),
        email: parts[2].trim(),          // <-- trim ici
        password: parts[3].trim(),       // <-- trim ici
        avatar: parts[4].isEmpty ? null : parts[4].trim(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          int.parse(parts[5].trim()),
        ),
      );
    }).toList();
  }

  // Sauvegarder l'utilisateur courant
  static Future<void> setCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final s =
        "${user.id}|${user.name}|${user.email}|${user.password}|${user.avatar ?? ''}|${user.createdAt.millisecondsSinceEpoch}";
    await prefs.setString(currentUserKey, s);
  }

  // Récupérer l'utilisateur courant
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(currentUserKey);
    if (s == null) return null;

    final parts = s.split('|');
    return User(
      id: parts[0],
      name: parts[1],
      email: parts[2],
      password: parts[3],
      avatar: parts[4].isEmpty ? null : parts[4],
      createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[5])),
    );
  }



  // Supprimer l'utilisateur courant
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentUserKey);
  }
  ////////////////////////////////////PROJECTS/////////
  static const String _projectsKey = 'projects';

  Future<List<Project>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? jsonList = prefs.getStringList(_projectsKey);

    if (jsonList == null) return [];

    return jsonList
        .map((json) => Project.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> saveProject(Project project) async {
    final prefs = await SharedPreferences.getInstance();

    List<Project> projects = await getProjects();

    projects.add(project);

    List<String> jsonList =
    projects.map((p) => jsonEncode(p.toMap())).toList();

    await prefs.setStringList(_projectsKey, jsonList);
  }

  Future<List<Project>> getProjectsByUserId(String userId) async {
    List<Project> projects = await getProjects();

    return projects.where((p) => p.ownerId == userId).toList();
  }

  Future<void> updateProject(Project project) async {
    final prefs = await SharedPreferences.getInstance();

    List<Project> projects = await getProjects();

    int index = projects.indexWhere((p) => p.id == project.id);

    if (index != -1) {
      projects[index] = project;
    }

    List<String> jsonList =
    projects.map((p) => jsonEncode(p.toMap())).toList();

    await prefs.setStringList(_projectsKey, jsonList);
  }

  Future<void> deleteProject(String projectId) async {
    final prefs = await SharedPreferences.getInstance();

    List<Project> projects = await getProjects();

    projects.removeWhere((p) => p.id == projectId);

    List<String> jsonList =
    projects.map((p) => jsonEncode(p.toMap())).toList();

    await prefs.setStringList(_projectsKey, jsonList);
  }

////////////////////////////////////TASKS/////////
// Dans StorageService

  static const String _tasksKey = 'tasks';


  Future<List<Task>> getTasks() async {
    if (!_initialized) await init();
    final List<String>? jsonList = _prefs.getStringList(_tasksKey);
    if (jsonList == null) return [];
    return jsonList
        .map((json) => Task.fromMap(jsonDecode(json)))
        .toList();
  }


  Future<List<Task>> getTasksByProjectId(String projectId) async {
    List<Task> allTasks = await getTasks();
    return allTasks.where((t) => t.projectId == projectId).toList();
  }


  Future<void> saveTask(Task task) async {
    List<Task> allTasks = await getTasks();
    allTasks.add(task);
    List<String> jsonList =
    allTasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_tasksKey, jsonList);
  }


  Future<void> updateTask(Task task) async {
    List<Task> allTasks = await getTasks();
    final index = allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      allTasks[index] = task;
      List<String> jsonList =
      allTasks.map((t) => jsonEncode(t.toMap())).toList();
      await _prefs.setStringList(_tasksKey, jsonList);
    }
  }


  Future<void> deleteTask(String taskId) async {
    List<Task> allTasks = await getTasks();
    allTasks.removeWhere((t) => t.id == taskId);
    List<String> jsonList =
    allTasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_tasksKey, jsonList);
  }


}