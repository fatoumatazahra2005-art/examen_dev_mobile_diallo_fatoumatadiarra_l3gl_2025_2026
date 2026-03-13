
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';

import '../../models/Project.dart';
import '../../models/Task.dart';
import '../../providers/auth_provider.dart';
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
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;

    // Tâches du projet uniquement pour l'utilisateur connecté
    final projectTasks = taskProvider.tasks
        .where((t) => t.projectId == project.id && t.userId == currentUser?.id)
        .toList();

    // Statistiques
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(project: project),
                ),
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
                  content: const Text("Voulez-vous vraiment supprimer ce projet ?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () {
                        taskProvider.deleteTasksByProject(project.id);
                        projectProvider.deleteProject(project.id);
                        Navigator.pop(context); // ferme le dialogue
                        Navigator.pop(context); // retourne à la liste projets
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(projectId: project.id),
            ),
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

          /// LISTE TÂCHES
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