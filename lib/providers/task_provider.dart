import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService.instance;

  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  // ===== Getters =====
  bool get isLoading => _isLoading;

  List<Task> get tasks {
    var filtered = _tasks;

    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }

    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }


    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return filtered;
  }

  Map<TaskStatus, int> get taskCountByStatus {
    Map<TaskStatus, int> counts = {};
    for (var status in TaskStatus.values) {
      counts[status] = _tasks.where((t) => t.status == status).length;
    }
    return counts;
  }


  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }


  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _storageService.getTasksByProjectId(projectId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(Task task) async {
    await _storageService.saveTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _storageService.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _storageService.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final task = _tasks.firstWhere(
          (t) => t.id == taskId,
      orElse: () => throw Exception('Task not found'),
    );
    task.status = status;
    await _storageService.updateTask(task);
    notifyListeners();
  }


  Task? getTaskById(String taskId) {
    final filtered = _tasks.where((t) => t.id == taskId);
    return filtered.isNotEmpty ? filtered.first : null;
  }
}