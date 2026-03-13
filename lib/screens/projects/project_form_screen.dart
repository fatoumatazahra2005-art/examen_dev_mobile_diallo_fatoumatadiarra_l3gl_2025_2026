
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/Project.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/cards/project_card.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project; // null = création, non-null = modification

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();


  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  Color? _selectedColor;

  // Liste de couleurs prédéfinies
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project != null
        ? Color(widget.project!.color)
        : _colors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;

    final project = Project(
      id: widget.project?.id ?? UniqueKey().toString(),
      name: _nameController.text.trim(),
      ownerId: currentUser!.id,
      description: _descriptionController.text.trim(),
      color: _selectedColor!.value,
    );

    if (widget.project == null) {
      await projectProvider.createProject(project);
    } else {
      await projectProvider.updateProject(project);
    }

    Navigator.pop(context); // Retour à la liste des projets
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le projet' : 'Créer un projet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Formulaire
            Form(
              key: _formKey,
              child: Column(
                children: [

                  // Nom du projet
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du projet *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Le nom doit contenir au moins 3 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Sélecteur de couleur
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Sélectionnez une couleur :'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: isSelected ? 24 : 20,
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            /// Aperçu en temps réel
            const SizedBox(height: 16),
            const Text('Aperçu du projet :'),
            const SizedBox(height: 8),
            ProjectCard(
              name: _nameController.text,
              description: _descriptionController.text,
              color: _selectedColor ?? _colors[0],
              taskCount: 0,
              onTap: () {},
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProject,
              child: Text(isEditing ? 'Modifier' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }
}