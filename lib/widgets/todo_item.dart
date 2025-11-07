import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import 'custom_button.dart';

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
    return GetBuilder<TodoController>(
      builder: (controller) {
        final isEditing = todo.status == TodoStatus.editing;
        final isToggling = controller.isToggling(todo.id);
        final isEditingLoading = controller.isEditing(todo.id);
        final isDeleting = controller.isDeleting(todo.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isEditing ? null : () => controller.toggleComplete(todo),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Index number
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isEditing)
                                TextField(
                                  controller:
                                      TextEditingController(text: todo.draft),
                                  onChanged: (value) =>
                                      controller.updateDraft(todo, value),
                                  onSubmitted: (value) =>
                                      controller.updateTodo(todo, value),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  todo.todo,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: todo.isCompleted
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade800,
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(todo.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: isToggling
                              ? null
                              : () => controller.toggleComplete(todo),
                          icon: Icon((todo.isCompleted)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 8),

                        // Action buttons
                        if (isEditing)
                          CustomButton(
                            label: isEditingLoading ? 'Saving...' : 'Save',
                            onPressed: isEditingLoading
                                ? null
                                : () => controller.updateTodo(
                                    todo, todo.draft ?? todo.todo),
                            icon: Icons.check,
                            backgroundColor: Colors.green.shade50,
                            textColor: Colors.green.shade700,
                            isLoading: isEditingLoading,
                          )
                        else
                          CustomButton(
                            label: 'Edit',
                            onPressed:
                                (isEditingLoading || isToggling || isDeleting)
                                    ? null
                                    : () => controller.enterEditMode(todo),
                            icon: Icons.edit,
                            backgroundColor: Colors.blue.shade50,
                            textColor: Colors.blue.shade700,
                          ),

                        const SizedBox(width: 8),

                        CustomButton(
                          label: isDeleting ? 'Deleting...' : 'Delete',
                          onPressed: isDeleting
                              ? null
                              : () => controller.deleteTodo(todo),
                          icon: Icons.delete,
                          backgroundColor: Colors.red.shade50,
                          textColor: Colors.red.shade700,
                          isLoading: isDeleting,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
