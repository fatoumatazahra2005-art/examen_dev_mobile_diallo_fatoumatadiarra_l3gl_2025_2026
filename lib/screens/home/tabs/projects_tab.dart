import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../widgets/cards/project_card.dart';
import '../../projects/project_detail_screen.dart';
import '../../projects/project_form_screen.dart';
//import '../../../models/Project.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);

    // Etat loading
   /** if (projectProvider.isLoading) {
      return const Center(
        child: LoadingIndicator(),
      );
    }**/

    final projects = projectProvider.projects;


    // Etat vide
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.folder_open, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Aucun projet pour le moment",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Liste des projets
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final taskProvider = Provider.of<TaskProvider>(context); // instance
        final taskCount = taskProvider.tasks
            .where((t) => t.projectId == project.id)
            .length;


        return ProjectCard(
          name: project.name,
          description: project.description ?? "",
          color: Color(project.color),
          taskCount: taskCount,

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(project: project),
              ),
            );
          },

          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectFormScreen(project: project),
              ),
            );
          },

          onDelete: () {
            projectProvider.deleteProject(project.id);
          },
        );
      },
    );
  }
}