import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import '../../../services/storage_service.dart';
import '../../../models/Project.dart';
import '../../../models/Task.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {

  List<Project> projects = [];
  List<Task> tasks = [];

  int todo = 0;
  int inProgress = 0;
  int done = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Charger les données
  Future<void> loadData() async {

    final storage = StorageService.instance;

    projects = await storage.getProjects();
    tasks = await storage.getTasks();

    todo = tasks.where((t) => t.status == "todo").length;
    inProgress = tasks.where((t) => t.status == "inProgress").length;
    done = tasks.where((t) => t.status == "done").length;

    setState(() {});
  }


  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Bonjour";
    } else if (hour < 18) {
      return "Bon après-midi";
    } else {
      return "Bonsoir";
    }
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(

      onRefresh: loadData,

      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [


          Text(
            getGreeting(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// CARTES STATISTIQUES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              statCard("Projets", projects.length, AppColors.successLight),

              statCard("Todo", todo, AppColors.statusTodo),

              statCard("En cours", inProgress, AppColors.statusInProgress),

              statCard("Terminés", done, AppColors.statusDone),

            ],
          ),

          const SizedBox(height: 30),
          const Text(
            "Projets récents",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (projects.isEmpty)
            const Text("Aucun projet pour le moment"),

          ...projects.take(3).map((project) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.folder),
                title: Text(project.name),
                subtitle: Text(project.description ?? ""),
              ),
            );
          })

        ],
      ),
    );
  }

  /// Widget carte statistique
  Widget statCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}