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