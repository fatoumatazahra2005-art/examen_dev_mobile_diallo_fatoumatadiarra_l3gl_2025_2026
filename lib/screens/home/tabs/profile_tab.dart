
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/User.dart';


class ProfileTab extends StatelessWidget {
  final User user;
  final int projectsCount;
  final int tasksCount;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.user,
    required this.projectsCount,
    required this.tasksCount,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : const AssetImage('assets/default_avatar.png')
            as ImageProvider,
          ),
          const SizedBox(height: 16),
          // Nom et email
          Text(
            user.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(fontSize: 16,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          // Date d'inscription
          Text(
            'Inscrit depuis : ${user.createdAt.toLocal().toShortDateString()}',
            style: const TextStyle(fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight:  FontWeight.bold
            ),
          ),
          const SizedBox(height: 24),
          // Statistiques personnelles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Projets', projectsCount),
              _buildStatCard('Tâches', tasksCount),
            ],
          ),
          const SizedBox(height: 32),
          // Bouton de déconnexion
          ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion'),
            style: ElevatedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Text(
              '$count',
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension pour formater la date
extension DateTimeExtension on DateTime {
  String toShortDateString() {
    return '${day.toString().padLeft(2,'0')}/${month.toString().padLeft(2,'0')}/${year}';
  }
}