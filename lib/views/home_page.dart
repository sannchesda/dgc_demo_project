import 'package:dgc_demo_project/controllers/todo_controller.dart';
import 'package:dgc_demo_project/models/todo.dart';
import 'package:dgc_demo_project/widgets/custom_button.dart';
import 'package:dgc_demo_project/widgets/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dgc_demo_project/widgets/states.dart' as ui_states;

import 'add_todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TodoController controller = Get.find<TodoController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Todo Apps',
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
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search todos...',
                        prefixIcon: const Icon(Icons.search),
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
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    label: 'Add',
                    onPressed: () => Get.to(() => const AddTodoPage()),
                    icon: Icons.add,
                  ),
                ],
              ),
            ),
          ),
          // Sorting and filtering options
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(
              () => Row(
                children: [
                  Text(
                    'Sort by: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: TodoSortOption.values.map((option) {
                          final isSelected =
                              controller.currentSortOption.value == option;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                option.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: Theme.of(context).primaryColor,
                              backgroundColor: Colors.grey.shade100,
                              onSelected: (_) =>
                                  controller.setSortOption(option),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.sortAscending.value
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 18,
                    ),
                    onPressed: () => controller
                        .setSortOption(controller.currentSortOption.value),
                    tooltip: controller.sortAscending.value
                        ? 'Ascending'
                        : 'Descending',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final status = controller.status;
              final filteredTodos = controller.filteredTodos;
              final searchQuery = controller.currentSearchQuery;
              final allTodos = controller.todos;

              // Loading state
              if (status == LoadingState.loading) {
                return const ui_states.LoadingState(
                  message: 'Loading todos...',
                );
              }

              // Error state
              if (status == LoadingState.error) {
                return RefreshIndicator(
                  onRefresh: controller.refreshTodos,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ui_states.ErrorState(
                        message:
                            'Failed to load todos. Please try again.\nPull down to refresh.',
                        onRetry: () => controller.refreshTodos(),
                      ),
                    ),
                  ),
                );
              }

              // Empty state - no todos
              if (allTodos.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshTodos,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ui_states.EmptyState(
                        title: 'No todos yet',
                        subtitle:
                            'Add your first todo above to get started!\nPull down to refresh.',
                        icon: Icons.checklist,
                        onActionPressed: () {
                          controller.addTodoController.text = '';
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        actionText: 'Add Todo',
                      ),
                    ),
                  ),
                );
              }

              // No search results
              if (filteredTodos.isEmpty && searchQuery.isNotEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshTodos,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ui_states.EmptyState(
                        title: 'No results found',
                        subtitle:
                            'Try searching with different keywords or create a new todo.\nPull down to refresh.',
                        icon: Icons.search_off,
                        onActionPressed: controller.clearSearch,
                        actionText: 'Clear Search',
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshTodos,
                child: ListView.builder(
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
                ),
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
