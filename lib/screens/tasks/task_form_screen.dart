import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // null = création, non-null = modification
  final String projectId; // ID du projet auquel la tâche appartient


  const TaskFormScreen({super.key, this.task, required this.projectId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? TaskStatus.todo;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Enregistre ou met à jour la tâche
  void _saveTask() async {
    if (!_formKey.currentState!.validate() || _dueDate == null) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;

    final task = Task(
      id: widget.task?.id ?? UniqueKey().toString(),
      projectId: widget.projectId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate!,
      userId: currentUser!.id,
    );

    if (widget.task == null) {
      await taskProvider.createTask(task);
    } else {
      await taskProvider.updateTask(task);
    }

    Navigator.pop(context);
  }

  /// Supprime la tâche avec confirmation
  void _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la tâche"),
        content: const Text("Voulez-vous vraiment supprimer cette tâche ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.deleteTask(widget.task!.id);
      Navigator.pop(context);
    }
  }

  /// Sélecteur de date
  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  /// Widget pour choisir un statut ou une priorité
  Widget _selector<T>(String label, List<T> options, T selected, ValueChanged<T> onSelect) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              option.toString().split('.').last, //  "todo", "inProgress" .
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier la tâche" : "Créer une tâche"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Titre *",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Sélecteur de statut
              const Text("Statut :"),
              const SizedBox(height: 8),
              _selector<TaskStatus>(
                  "Statut",
                  TaskStatus.values,
                  _status,
                      (val) => setState(() => _status = val)),
              const SizedBox(height: 16),

              // Sélecteur de priorité
              const Text("Priorité :"),
              const SizedBox(height: 8),
              _selector<TaskPriority>(
                  "Priorité",
                  TaskPriority.values,
                  _priority,
                      (val) => setState(() => _priority = val)),
              const SizedBox(height: 16),

              // Date d’échéance
              Row(
                children: [
                  const Text("Échéance : "),
                  Text(_dueDate != null
                      ? "${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}"
                      : "Non sélectionnée"),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickDueDate,
                    child: const Text("Choisir la date"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bouton enregistrer
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? "Modifier" : "Créer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}