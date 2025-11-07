class Todo {
  final String id;
  final String todo;
  final bool isCompleted;
  final DateTime createdAt;
  final TodoStatus status;
  final String? draft; // For editing mode

  Todo({
    required this.id,
    required this.todo,
    required this.isCompleted,
    required this.createdAt,
    this.status = TodoStatus.viewing,
    this.draft,
  });

  // Factory constructor for creating from Firestore document
  factory Todo.fromMap(Map<String, dynamic> map, String documentId) {
    return Todo(
      id: documentId,
      todo: map['todo'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      status: TodoStatus.viewing,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'todo': todo,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with method for state updates
  Todo copyWith({
    String? id,
    String? todo,
    bool? isCompleted,
    DateTime? createdAt,
    TodoStatus? status,
    String? draft,
  }) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      draft: draft ?? this.draft,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, todo: $todo, isCompleted: $isCompleted, createdAt: $createdAt, status: $status, draft: $draft)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum TodoStatus {
  editing,
  viewing,
}

enum LoadingState {
  loading,
  done,
  error,
}
