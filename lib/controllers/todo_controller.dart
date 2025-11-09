import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dgc_demo_project/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class TodoController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Uuid uuid = const Uuid();

  // Observable state variables
  final RxList<Todo> todoList = <Todo>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<LoadingState> loadingStatus = LoadingState.loading.obs;

  // Text controllers
  final searchController = TextEditingController();
  final addTodoController = TextEditingController();
  final addTodoDescriptionController = TextEditingController();

  // Additional state for UI
  final RxBool isAddingTodo = false.obs;
  final RxMap<String, bool> operationLoadingStates = <String, bool>{}.obs;
  final Rx<TodoPriority> selectedPriority = TodoPriority.medium.obs;
  final Rx<TodoSortOption> currentSortOption = TodoSortOption.dateCreated.obs;
  final RxBool sortAscending = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeTodos();
    setupSearchListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    addTodoController.dispose();
    addTodoDescriptionController.dispose();
    super.onClose();
  }

  void setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  // Getters
  List<Todo> get todos => todoList;

  String get currentSearchQuery => searchQuery.value;

  LoadingState get status => loadingStatus.value;

  bool get isCurrentlyAddingTodo => isAddingTodo.value;

  // Filtered and sorted todos
  List<Todo> get filteredTodos {
    // Always create a new list from todoList to avoid reactive issues
    List<Todo> filteredList = List<Todo>.from(todoList);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filteredList = filteredList
          .where((todo) =>
              todo.title.toLowerCase().contains(query) ||
              todo.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply sorting to the copy, never to the original reactive list
    switch (currentSortOption.value) {
      case TodoSortOption.dateCreated:
        filteredList.sort((a, b) => sortAscending.value
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case TodoSortOption.priority:
        filteredList.sort((a, b) => sortAscending.value
            ? a.priority.value.compareTo(b.priority.value)
            : b.priority.value.compareTo(a.priority.value));
        break;
      case TodoSortOption.title:
        filteredList.sort((a, b) => sortAscending.value
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case TodoSortOption.status:
        filteredList.sort((a, b) => sortAscending.value
            ? a.isCompleted.toString().compareTo(b.isCompleted.toString())
            : b.isCompleted.toString().compareTo(a.isCompleted.toString()));
        break;
    }

    return filteredList;
  }

  // Statistics getters for dashboard
  int get totalTodos => todoList.length;

  int get completedTodos => todoList.where((todo) => todo.isCompleted).length;

  int get pendingTodos => todoList.where((todo) => !todo.isCompleted).length;

  double get completionPercentage =>
      totalTodos == 0 ? 0 : (completedTodos / totalTodos) * 100;

  Map<TodoPriority, int> get todosByPriority {
    final result = <TodoPriority, int>{};
    for (final priority in TodoPriority.values) {
      result[priority] =
          todoList.where((todo) => todo.priority == priority).length;
    }
    return result;
  }

  Map<String, int> get todosCompletedByWeek {
    final now = DateTime.now();
    final result = <String, int>{};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.day}/${date.month}';
      result[dateKey] = todoList
          .where((todo) =>
              todo.isCompleted &&
              todo.updatedAt.day == date.day &&
              todo.updatedAt.month == date.month)
          .length;
    }

    return result;
  }

  // Loading state helpers
  bool isOperationLoading(String key) => operationLoadingStates[key] ?? false;

  bool isDeletingTodo(String todoId) => isOperationLoading('deleting-$todoId');

  bool isEditingTodo(String todoId) => isOperationLoading('editing-$todoId');

  bool isTogglingTodo(String todoId) => isOperationLoading('toggling-$todoId');

  void initializeTodos() {
    loadingStatus.value = LoadingState.loading;

    firestore.collection('todos').snapshots().listen(
      (snapshot) {
        final todos = snapshot.docs.where(
          (element) {
            // remove data that don't contain field 'title' or 'description'
            final data = element.data();
            return data.containsKey('title') && data.containsKey('description');
          },
        ).map((doc) {
          return Todo.fromMap(doc.data(), doc.id);
        }).toList();

        todoList.assignAll(todos);
        loadingStatus.value = LoadingState.done;
      },
      onError: (error) {
        debugPrint('Error fetching todos: $error');
        loadingStatus.value = LoadingState.error;
      },
    );
  }

  // Refresh method for pull-to-refresh functionality
  Future<void> refreshTodos() async {
    try {
      loadingStatus.value = LoadingState.loading;

      // Fetch fresh data from Firestore
      final snapshot = await firestore.collection('todos').get();
      final todos = snapshot.docs.where(
        (element) {
          // remove data that don't contain field 'title' or 'description'
          final data = element.data();
          return data.containsKey('title') && data.containsKey('description');
        },
      ).map((doc) {
        return Todo.fromMap(doc.data(), doc.id);
      }).toList();

      todoList.assignAll(todos);
      loadingStatus.value = LoadingState.done;
    } catch (error) {
      debugPrint('Error refreshing todos: $error');
      loadingStatus.value = LoadingState.error;
      showErrorSnackbar('Failed to refresh todos');
    }
  }

  Future<void> addTodo() async {
    final title = addTodoController.text.trim();
    final description = addTodoDescriptionController.text.trim();

    if (title.isEmpty || isAddingTodo.value) return;

    // Check for duplicates
    if (todoList
        .any((todo) => todo.title.toLowerCase() == title.toLowerCase())) {
      Get.dialog(
        AlertDialog(
          title: const Text('Duplicate Item'),
          content: Text('A todo with the title "$title" already exists.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    isAddingTodo.value = true;

    try {
      final newTodo = Todo(
        id: uuid.v4(),
        title: title,
        description: description,
        isCompleted: false,
        createdAt: DateTime.now(),
        priority: selectedPriority.value,
      );

      await firestore.collection('todos').doc(newTodo.id).set(newTodo.toMap());

      clearAddTodoForm();
      showSuccessSnackbar('Todo created successfully');
    } catch (error) {
      debugPrint('Error creating todo: $error');
      showErrorSnackbar('Failed to create todo');
    } finally {
      isAddingTodo.value = false;
    }
  }

  Future<void> createTodo(
      String title, String description, TodoPriority priority) async {
    try {
      final newTodo = Todo(
        id: uuid.v4(),
        title: title,
        description: description,
        isCompleted: false,
        createdAt: DateTime.now(),
        priority: priority,
      );

      await firestore.collection('todos').doc(newTodo.id).set(newTodo.toMap());
    } catch (error) {
      debugPrint('Error creating todo: $error');
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await firestore.collection('todos').doc(todo.id).update(todo.toMap());
    } catch (error) {
      debugPrint('Error updating todo: $error');
      rethrow;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await firestore.collection('todos').doc(todoId).delete();
    } catch (error) {
      debugPrint('Error deleting todo: $error');
      rethrow;
    }
  }

  Future<void> toggleTodoCompletion(Todo todo) async {
    final loadingKey = 'toggling-${todo.id}';
    if (isOperationLoading(loadingKey)) return;

    operationLoadingStates[loadingKey] = true;
    update();

    try {
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        updatedAt: DateTime.now(),
      );
      await updateTodo(updatedTodo);

      final status = updatedTodo.isCompleted ? 'completed' : 'pending';
      showSuccessSnackbar('Todo marked as $status');
    } catch (error) {
      debugPrint('Error toggling todo completion: $error');
      showErrorSnackbar('Failed to update todo status');
    } finally {
      operationLoadingStates.remove(loadingKey);
      update();
    }
  }

  Future<void> deleteTodoWithConfirmation(Todo todo) async {
    final loadingKey = 'deleting-${todo.id}';
    if (isOperationLoading(loadingKey)) return;

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    operationLoadingStates[loadingKey] = true;
    update();

    try {
      await deleteTodo(todo.id);
      showSuccessSnackbar('Todo deleted successfully');
    } catch (error) {
      debugPrint('Error deleting todo: $error');
      showErrorSnackbar('Failed to delete todo');
    } finally {
      operationLoadingStates.remove(loadingKey);
      update();
    }
  }

  void setSortOption(TodoSortOption option) {
    if (currentSortOption.value == option) {
      // Toggle sort direction if same option is selected
      sortAscending.value = !sortAscending.value;
    } else {
      currentSortOption.value = option;
      sortAscending.value = false; // Default to descending for new option
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void clearAddTodoForm() {
    addTodoController.clear();
    addTodoDescriptionController.clear();
    selectedPriority.value = TodoPriority.medium;
  }

  void showSuccessSnackbar(String message) {
    // Find the current context from the navigation
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void showErrorSnackbar(String message) {
    // Find the current context from the navigation
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
