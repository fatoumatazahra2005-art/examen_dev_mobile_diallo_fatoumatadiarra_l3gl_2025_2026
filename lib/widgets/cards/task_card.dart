import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case "todo":
        return AppColors.statusTodo;
      case "inProgress":
        return AppColors.statusInProgress;
      case "done":
        return AppColors.statusDone;
      default:
        return AppColors.statusTodo;
    }
  }

  Color _getPriorityColor() {
    switch (priority) {
      case "low":
        return AppColors.priorityLow;
      case "medium":
        return AppColors.priorityMedium;
      case "high":
        return AppColors.priorityHigh;
      default:
        return AppColors.priorityLow;
    }
  }

  IconData _getPriorityIcon() {
    switch (priority) {
      case "low":
        return Icons.arrow_downward;
      case "medium":
        return Icons.remove;
      case "high":
        return Icons.arrow_upward;
      default:
        return Icons.flag;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Titre
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              /// Description
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// Priorité
                  Row(
                    children: [
                      Icon(
                        _getPriorityIcon(),
                        color: _getPriorityColor(),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        priority,
                        style: TextStyle(
                          color: _getPriorityColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// Date d’échéance
              if (dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(_formatDate(dueDate!)),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}