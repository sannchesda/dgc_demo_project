import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/todo.dart';

class TodoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Observable state variables
  final RxList<Todo> _todos = <Todo>[].obs;
  final RxString _searchQuery = ''.obs;
  final Rx<LoadingState> _status = LoadingState.loading.obs;
  final RxMap<String, bool> _loadingStates = <String, bool>{}.obs;
  final RxBool _isAddingTodo = false.obs;

  // Text controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController addTodoController = TextEditingController();

  // Getters
  List<Todo> get todos => _todos;
  String get searchQuery => _searchQuery.value;
  LoadingState get status => _status.value;
  bool get isAddingTodo => _isAddingTodo.value;

  // Filtered todos based on search query
  List<Todo> get filteredTodos {
    if (_searchQuery.value.isEmpty) {
      return _todos;
    }
    return _todos
        .where((todo) =>
            todo.todo.toLowerCase().contains(_searchQuery.value.toLowerCase()))
        .toList();
  }

  // Loading state helpers
  bool isLoading(String key) => _loadingStates[key] ?? false;
  bool isDeleting(String todoId) => isLoading('deleting-$todoId');
  bool isEditing(String todoId) => isLoading('editing-$todoId');
  bool isToggling(String todoId) => isLoading('toggling-$todoId');

  @override
  void onInit() {
    super.onInit();
    _initializeTodos();
    _setupSearchListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    addTodoController.dispose();
    super.onClose();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });
  }

  void _initializeTodos() {
    _status.value = LoadingState.loading;

    _firestore.collection('todos').snapshots().listen(
      (snapshot) {
        final todoList = snapshot.docs.map((doc) {
          return Todo.fromMap(doc.data(), doc.id);
        }).toList();

        // Sort by creation date (newest first)
        todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        _todos.assignAll(todoList);
        _status.value = LoadingState.done;
      },
      onError: (error) {
        print('Error fetching todos: $error');
        _status.value = LoadingState.error;
        Get.snackbar(
          'Error',
          'Failed to fetch todos',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      },
    );
  }

  void addTodo() async {
    final todoText = addTodoController.text.trim();

    if (todoText.isEmpty || _isAddingTodo.value) return;

    // Check for duplicates
    if (_todos
        .any((todo) => todo.todo.toLowerCase() == todoText.toLowerCase())) {
      Get.dialog(
        AlertDialog(
          title: const Text('Duplicate Item'),
          content: Text('A todo with the text "$todoText" already exists.'),
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

    _isAddingTodo.value = true;

    try {
      final newTodo = Todo(
        id: _uuid.v4(),
        todo: todoText,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('todos').doc(newTodo.id).set(newTodo.toMap());

      addTodoController.clear();
      searchController.clear();
      _searchQuery.value = '';

      Get.snackbar(
        'Success',
        'Todo added successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (error) {
      print('Error adding todo: $error');
      Get.snackbar(
        'Error',
        'Failed to add todo',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      _isAddingTodo.value = false;
    }
  }

  void deleteTodo(Todo todo) async {
    final loadingKey = 'deleting-${todo.id}';

    if (isLoading(loadingKey)) return;

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.todo}"?'),
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

    _loadingStates[loadingKey] = true;
    update();

    try {
      await _firestore.collection('todos').doc(todo.id).delete();

      Get.snackbar(
        'Success',
        'Todo deleted successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (error) {
      print('Error deleting todo: $error');
      Get.snackbar(
        'Error',
        'Failed to delete todo',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      _loadingStates.remove(loadingKey);
      update();
    }
  }

  void updateTodo(Todo todo, String newText) async {
    final loadingKey = 'editing-${todo.id}';

    if (newText.trim() == todo.todo.trim()) {
      // No changes, just exit edit mode
      _exitEditMode(todo);
      return;
    }

    if (isLoading(loadingKey)) return;

    _loadingStates[loadingKey] = true;
    update();

    try {
      final updatedData = {
        'todo': newText.trim(),
        'isCompleted': todo.isCompleted,
        'createdAt': todo.createdAt.toIso8601String(),
      };

      await _firestore.collection('todos').doc(todo.id).update(updatedData);

      _exitEditMode(todo);

      Get.snackbar(
        'Success',
        'Todo updated successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (error) {
      print('Error updating todo: $error');
      Get.snackbar(
        'Error',
        'Failed to update todo',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      _loadingStates.remove(loadingKey);
      update();
    }
  }

  void toggleComplete(Todo todo) async {
    final loadingKey = 'toggling-${todo.id}';

    if (isLoading(loadingKey)) return;

    _loadingStates[loadingKey] = true;
    update();

    try {
      final updatedData = {
        'todo': todo.todo,
        'isCompleted': !todo.isCompleted,
        'createdAt': todo.createdAt.toIso8601String(),
      };

      await _firestore.collection('todos').doc(todo.id).update(updatedData);
    } catch (error) {
      print('Error toggling todo completion: $error');
      Get.snackbar(
        'Error',
        'Failed to update todo',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      _loadingStates.remove(loadingKey);
      update();
    }
  }

  void enterEditMode(Todo todo) {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        status: TodoStatus.editing,
        draft: todo.todo,
      );
    }
  }

  void _exitEditMode(Todo todo) {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        status: TodoStatus.viewing,
        draft: null,
      );
    }
  }

  void updateDraft(Todo todo, String draft) {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(draft: draft);
    }
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery.value = '';
  }
}
