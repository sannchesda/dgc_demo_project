import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import '../views/add_todo_page.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final int index;

  const TodoItem({
    super.key,
    required this.todo,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: _getPriorityColor(),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey..withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) => controller.toggleTodoCompletion(todo),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
        subtitle: todo.description.isNotEmpty ? Text(todo.description) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Get.to(() => AddTodoPage(editTodo: todo)),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => controller.deleteTodoWithConfirmation(todo),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (todo.isCompleted) {
      return Colors.grey.shade100; // Muted color for completed todos
    }

    switch (todo.priority) {
      case TodoPriority.high:
        return Colors.red.shade50; // Light red for high priority
      case TodoPriority.medium:
        return Colors.orange.shade50; // Light orange for medium priority
      case TodoPriority.low:
        return Colors.green.shade50; // Light green for low priority
      default:
        return Colors.white;
    }
  }

  /// Returns priority indicator color for the left border
  Color _getPriorityColor() {
    if (todo.isCompleted) {
      return Colors.grey.shade400; // Muted color for completed todos
    }

    switch (todo.priority) {
      case TodoPriority.high:
        return Colors.red.shade400; // Red for high priority
      case TodoPriority.medium:
        return Colors.orange.shade400; // Orange for medium priority
      case TodoPriority.low:
        return Colors.green.shade400; // Green for low priority
      default:
        return Colors.grey.shade300;
    }
  }
}
