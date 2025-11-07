import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import '../widgets/custom_button.dart';
import '../widgets/states.dart' as ui_states;
import '../widgets/todo_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.put(TodoController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Todo App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.shade200,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          // Add Todo Section
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Add todo form
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.addTodoController,
                          decoration: InputDecoration(
                            hintText: 'Enter a new todo...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            // Update search as user types
                            controller.searchController.text = value;
                          },
                          onSubmitted: (value) => controller.addTodo(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => PrimaryButton(
                            label:
                                controller.isAddingTodo ? 'Adding...' : 'Add',
                            onPressed: controller.addTodo,
                            isLoading: controller.isAddingTodo,
                            icon: Icons.add,
                          )),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search field
                  TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search todos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Obx(
                        () => controller.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clearSearch,
                              )
                            : const SizedBox.shrink(),
                      ),
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
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Todo List
          Expanded(
            child: Obx(() {
              final status = controller.status;
              final filteredTodos = controller.filteredTodos;
              final searchQuery = controller.searchQuery;
              final allTodos = controller.todos;

              // Loading state
              if (status == LoadingState.loading) {
                return const ui_states.LoadingState(
                    message: 'Loading todos...');
              }

              // Error state
              if (status == LoadingState.error) {
                return ui_states.ErrorState(
                  message: 'Failed to load todos. Please try again.',
                  onRetry: () => controller.onInit(),
                );
              }

              // Empty state - no todos
              if (allTodos.isEmpty) {
                return ui_states.EmptyState(
                  title: 'No todos yet',
                  subtitle: 'Add your first todo above to get started!',
                  icon: Icons.checklist,
                  onActionPressed: () {
                    // Focus on the add todo field
                    controller.addTodoController.text = '';
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  actionText: 'Add Todo',
                );
              }

              // No search results
              if (filteredTodos.isEmpty && searchQuery.isNotEmpty) {
                return ui_states.EmptyState(
                  title: 'No results found',
                  subtitle:
                      'Try searching with different keywords or create a new todo.',
                  icon: Icons.search_off,
                  onActionPressed: controller.clearSearch,
                  actionText: 'Clear Search',
                );
              }

              // Todo list
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = filteredTodos[index];
                  final originalIndex = allTodos.indexOf(todo);

                  return TodoItem(
                    todo: todo,
                    index: originalIndex,
                  );
                },
              );
            }),
          ),
        ],
      ),

      // Stats bottom bar
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final allTodos = controller.todos;
              final completedCount =
                  allTodos.where((todo) => todo.isCompleted).length;
              final totalCount = allTodos.length;
              final pendingCount = totalCount - completedCount;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Total',
                    value: totalCount.toString(),
                    color: Colors.blue,
                    icon: Icons.list_alt,
                  ),
                  _StatItem(
                    label: 'Pending',
                    value: pendingCount.toString(),
                    color: Colors.orange,
                    icon: Icons.pending_actions,
                  ),
                  _StatItem(
                    label: 'Completed',
                    value: completedCount.toString(),
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
