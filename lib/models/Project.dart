/**
 * Les modèles sont immutables (final) pour éviter les
 * modifications et faciliter la gestion d'état
 */
class Project {

  /// Identifiant unique du projet (UUID)
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime createdAt;

  /// Constructeur
  Project({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /**
   * Crée une copie du projet avec certains champs modifiés
   * Ex: final updatedProject = project.copyWith(name: 'Nouveau Projet')
   */
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    int? color,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,

      createdAt: createdAt ?? this.createdAt,
    );
  }

  /**
   * Convertir le projet en Map pour la sérialisation
   * Utile pour sauvegarder dans SharedPreferences ou envoyer à une API
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,

      'createdAt': createdAt.toString(),
    };
  }

  /**
   * Créer un projet à partir d'une Map
   */
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      ownerId: map['ownerId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, ownerId: $ownerId)';
  }
}