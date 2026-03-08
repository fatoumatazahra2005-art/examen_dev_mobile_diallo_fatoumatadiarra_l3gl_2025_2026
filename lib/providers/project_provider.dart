import 'package:flutter/material.dart';
//import '../models/Project.dart';
import '../models/Project.dart';
import '../services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService.instance;

  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  // ===== Getters =====
  List<Project> get projects => _projects;

  Project? get selectedProject => _selectedProject;

  int get projectCount => _projects.length;

  bool get isLoading => _isLoading;

  // ===== Charger les projets d'un utilisateur =====
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await _storageService.getProjectsByUserId(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> createProject(Project project) async {
    await _storageService.saveProject(project);
    _projects.add(project);
    notifyListeners();
  }


  Future<void> updateProject(Project project) async {
    await _storageService.updateProject(project);

    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }


  Future<void> deleteProject(String projectId) async {
    await _storageService.deleteProject(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }


  void selectProject(Project? project) {
    if (project == null || _projects.any((p) => p.id == project.id)) {
      _selectedProject = project;
      notifyListeners();
    }
  }


  void clearSelection() {
    _selectedProject = null;
    notifyListeners();
  }


  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }
}