class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TodoPriority priority;
  final TodoStatus status;
  final String? draft; // For editing mode

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    required this.isCompleted,
    required this.createdAt,
    DateTime? updatedAt,
    this.priority = TodoPriority.medium,
    this.status = TodoStatus.viewing,
    this.draft,
  }) : updatedAt = updatedAt ?? createdAt;

  // Factory constructor for creating from Firestore document
  factory Todo.fromMap(Map<String, dynamic> map, String documentId) {
    return Todo(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      priority: TodoPriority.values.firstWhere(
        (p) => p.name == (map['priority'] ?? 'medium'),
        orElse: () => TodoPriority.medium,
      ),
      status: TodoStatus.viewing,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'priority': priority.name,
    };
  }

  // Copy with method for state updates
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    TodoPriority? priority,
    TodoStatus? status,
    String? draft,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      priority: priority ?? this.priority,
      status: status ?? this.status,
      draft: draft ?? this.draft,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, description: $description, isCompleted: $isCompleted, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, draft: $draft)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum TodoPriority {
  low('Low', 1),
  medium('Medium', 2),
  high('High', 3),
  urgent('Urgent', 4);

  const TodoPriority(this.label, this.value);

  final String label;
  final int value;
}

enum TodoStatus {
  editing,
  viewing,
}

enum TodoSortOption {
  dateCreated('Date Created'),
  priority('Priority'),
  title('Title'),
  status('Status');

  const TodoSortOption(this.label);
  final String label;
}

enum LoadingState {
  loading,
  done,
  error,
}
