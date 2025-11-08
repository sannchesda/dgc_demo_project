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
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: getPriorityColor(),
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

  Color getBackgroundColor() {
    switch (todo.priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.urgent:
        return Colors.purple;
    }
  }

  Color getPriorityColor() {
    switch (todo.priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.urgent:
        return Colors.purple;
    }
  }
}
