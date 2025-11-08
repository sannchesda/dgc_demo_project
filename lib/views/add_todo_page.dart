import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import '../widgets/custom_button.dart';

class AddTodoPage extends StatefulWidget {
  final Todo? editTodo; // If provided, we're editing; if null, we're creating

  const AddTodoPage({super.key, this.editTodo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TodoController controller = Get.find<TodoController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxBool isLoading = false.obs;
  late Rx<TodoPriority> selectedPriority;

  bool get isEditing => widget.editTodo != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Pre-fill form for editing
      titleController.text = widget.editTodo!.title;
      descriptionController.text = widget.editTodo!.description;
      selectedPriority = widget.editTodo!.priority.obs;
    } else {
      selectedPriority = TodoPriority.medium.obs;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Todo' : 'Add New Todo',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.shade200,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter todo title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Description Field
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter todo description (optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Priority Selection
            const Text(
              'Priority',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  children: TodoPriority.values.map((priority) {
                    final isSelected = selectedPriority.value == priority;
                    return ChoiceChip(
                      label: Text(
                        priority.label,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _getPriorityColor(priority),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? _getPriorityColor(priority)
                            : Colors.grey.shade300,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          selectedPriority.value = priority;
                        }
                      },
                    );
                  }).toList(),
                )),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => PrimaryButton(
                      label: isEditing ? 'Update Todo' : 'Create Todo',
                      onPressed: () => _saveTodo(),
                      isLoading: isLoading.value,
                      icon: isEditing ? Icons.edit : Icons.add,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
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

  Future<void> _saveTodo() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a todo title',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isLoading.value = true;

    try {
      if (isEditing) {
        // Update existing todo
        final updatedTodo = widget.editTodo!.copyWith(
          title: title,
          description: descriptionController.text.trim(),
          priority: selectedPriority.value,
          updatedAt: DateTime.now(),
        );
        await controller.updateTodo(updatedTodo);
        controller.showSuccessSnackbar('Todo updated successfully');
      } else {
        // Create new todo
        await controller.createTodo(
          title,
          descriptionController.text.trim(),
          selectedPriority.value,
        );
        controller.showSuccessSnackbar('Todo created successfully');
      }

      Get.back();
    } catch (error) {
      controller.showErrorSnackbar(
        isEditing ? 'Failed to update todo' : 'Failed to create todo',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
