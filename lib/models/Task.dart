
enum TaskStatus { todo, inProgress, done }
enum TaskPriority { low, medium, high }

class Task {
  String id;
  String projectId;
  String title;
  String description;
  String userId;
  TaskStatus status;
  TaskPriority priority;
  DateTime dueDate;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.userId,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    required this.dueDate,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'userId': userId,
      'status': status.index,
      'priority': priority.index,
      'dueDate': dueDate.toString(),
    };
  }


  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      projectId: map['projectId'],
      title: map['title'],
      description: map['description'],
      userId: map['userId'],
      status: TaskStatus.values[map['status']],
      priority: TaskPriority.values[map['priority']],
      dueDate: DateTime.parse(map['dueDate']),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, name: $title, description: $description , status: $status , priority: $priority ,dueDate: $dueDate)';
  }
}