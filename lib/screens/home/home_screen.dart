import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/screens/home/tabs/tasks_tab.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
//Center(child: Text("Dashboard")),
  //Center(child: Text("Projets")),
  //Center(child: Text("Tâches")),
  // Center(child: Text("Profil")),
  /**final List<Widget> _pages = [
   DashboardTab(),
    ProjectsTab(),
    TasksTab(tasks: []),
    ProfileTab(
      //user: currentUser,
      projectsCount: 5,
      tasksCount: 42,
      onLogout: () {
        print('Utilisateur déconnecté');
      },
    )
  ];**/

  void _onTabSelected(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (projectProvider.projects.isEmpty && !projectProvider.isLoading) {
      projectProvider.loadProjects(user.id);
    }
    if (taskProvider.tasks.isEmpty && !taskProvider.isLoading) {
      taskProvider.loadTasks(user.id);
    }

    final projectsCount = projectProvider.projectCount;
    final tasksCount = taskProvider.getTaskCountByUser(user.id);
    final userTasks = taskProvider.getTasksByUserId(user.id);

    final pages = [
      DashboardTab(),
      ProjectsTab(),
      TasksTab(tasks: userTasks),
      ProfileTab(
        user: user,
        projectsCount: projectsCount,
        tasksCount: tasksCount,
        onLogout: () async {
          await authProvider.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    ];

    return Scaffold(

      /// APP BAR
      appBar: AppBar(
        title: const Text("Sunu Task"),
      ),

      /// DRAWER
      drawer: Drawer(
        child: Column(
          children: [

            /// HEADER
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? ""),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  user?.name.substring(0,1).toUpperCase() ?? "",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            /// NAVIGATION ITEMS
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: (){
                _onTabSelected(0);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text("Projets"),
              onTap: (){
                _onTabSelected(1);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Tâches"),
              onTap: (){
                _onTabSelected(2);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profil"),
              onTap: (){
                _onTabSelected(3);
                Navigator.pop(context);
              },
            ),

            const Divider(),

            /// LOGOUT
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Déconnexion"),
              onTap: (){
                authProvider.logout();
              },
            ),

          ],
        ),
      ),

      /// BODY AVEC INDEXEDSTACK
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      /// FLOATING BUTTON
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
        onPressed: () {
          print("Créer un nouveau projet");
        },
        child: const Icon(Icons.add),
      )
          : null,

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Projets",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Tâches",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),

        ],
      ),

    );
  }
}