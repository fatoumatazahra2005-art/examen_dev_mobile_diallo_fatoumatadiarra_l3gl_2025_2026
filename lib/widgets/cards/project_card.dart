import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String name;
  final String description;
  final Color color;
  final int taskCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.name,
    required this.description,
    required this.color,
    required this.taskCount,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        onTap: onTap,

        // Pastille couleur
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 10,
        ),

        // Nom + description
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$taskCount tâches"),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit?.call();
                } else if (value == 'delete') {
                  onDelete?.call();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Modifier'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}