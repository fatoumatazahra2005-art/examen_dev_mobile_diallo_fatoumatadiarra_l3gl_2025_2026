// home/tabs/tasks_tab.dart
import 'package:flutter/material.dart';
import '../../../models/Task.dart';


class TasksTab extends StatefulWidget {
  final List<Task> tasks;

  const TasksTab({super.key, required this.tasks});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  TaskStatus? selectedStatus;
  TaskPriority? selectedPriority;

  List<Task> get filteredTasks {
    return widget.tasks.where((task) {
      final statusMatch = selectedStatus == null || task.status == selectedStatus;
      final priorityMatch = selectedPriority == null || task.priority == selectedPriority;
      return statusMatch && priorityMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtres
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Filtre statut
              Expanded(
                child: DropdownButton<TaskStatus>(
                  hint: const Text('Filtrer par statut'),
                  value: selectedStatus,
                  isExpanded: true,
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Filtre priorité
              Expanded(
                child: DropdownButton<TaskPriority>(
                  hint: const Text('Filtrer par priorité'),
                  value: selectedPriority,
                  isExpanded: true,
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // Liste des tâches ou état vide
        Expanded(
          child: filteredTasks.isEmpty
              ? const Center(
            child: Text(
              'Aucune tâche disponible',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                      'Statut: ${task.status.name} • Priorité: ${task.priority.name}\nÉchéance: ${task.dueDate.toLocal()}'),
                  leading: const Icon(Icons.task),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

