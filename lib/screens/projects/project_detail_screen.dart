import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/project.dart';
import '../../models/task.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/cards/task_card.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {

    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    final projectTasks =
    taskProvider.tasks.where((t) => t.projectId == project.id).toList();

    final todo = projectTasks.where((t) => t.status == TaskStatus.todo).length;
    final inProgress =
        projectTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final done = projectTasks.where((t) => t.status == TaskStatus.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du projet"),
        actions: [

          /// Modifier projet
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                "/editProject",
                arguments: project,
              );
            },
          ),

          /// Supprimer projet
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Supprimer le projet"),
                  content: const Text(
                      "Voulez-vous vraiment supprimer ce projet ?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () {
                        taskProvider.deleteTasksByProject(project.id);
                        projectProvider.deleteProject(project.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Supprimer"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/createTask",
            arguments: project,
          );
        },
        child: const Icon(Icons.add),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// HEADER PROJET
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(project.color),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  project.description ?? "",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// STATISTIQUES
          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text("Todo: $todo")),
              Chip(label: Text("En cours: $inProgress")),
              Chip(label: Text("Terminées: $done")),
            ],
          ),

          const SizedBox(height: 20),

          /// DATE CREATION
          Text(
            "Créé le : ${project.createdAt.toLocal()}",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          const Text(
            "Tâches",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// LISTE TACHES
          if (projectTasks.isEmpty)
            const Text("Aucune tâche pour ce projet"),

          ...projectTasks.map((task) {
            return TaskCard(
              title: task.title,
              description: task.description,
              status: task.status.name,
              priority: task.priority.name,
            );
          }).toList(),
        ],
      ),
    );
  }
}