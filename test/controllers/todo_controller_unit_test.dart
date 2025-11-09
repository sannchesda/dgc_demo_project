import 'package:flutter_test/flutter_test.dart';
import 'package:dgc_demo_project/controllers/todo_controller.dart';
import 'package:dgc_demo_project/models/todo.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('TodoController Unit Tests', () {
    late TodoController controller;

    setUp(() {
      TestHelpers.setupGetX();
      controller = TodoController();
    });

    tearDown(() {
      TestHelpers.cleanupGetX();
    });

    group('Initialization Tests', () {
      test('should initialize with correct default values', () {
        expect(controller.todoList, isEmpty);
        expect(controller.searchQuery.value, isEmpty);
        expect(controller.loadingStatus.value, equals(LoadingState.loading));
        expect(controller.isAddingTodo.value, equals(false));
        expect(controller.selectedPriority.value, equals(TodoPriority.medium));
        expect(controller.currentSortOption.value,
            equals(TodoSortOption.dateCreated));
        expect(controller.sortAscending.value, equals(false));
      });

      test('should have empty operation loading states initially', () {
        expect(controller.operationLoadingStates, isEmpty);
      });

      test('should have proper text controllers', () {
        expect(controller.searchController, isNotNull);
        expect(controller.addTodoController, isNotNull);
        expect(controller.addTodoDescriptionController, isNotNull);
      });
    });

    group('Form Management Tests', () {
      test('should clear add todo form correctly', () {
        // Arrange - Fill the form
        controller.addTodoController.text = 'Some title';
        controller.addTodoDescriptionController.text = 'Some description';
        controller.selectedPriority.value = TodoPriority.urgent;

        // Act
        controller.clearAddTodoForm();

        // Assert
        expect(controller.addTodoController.text, isEmpty);
        expect(controller.addTodoDescriptionController.text, isEmpty);
        expect(controller.selectedPriority.value, equals(TodoPriority.medium));
      });

      test('should update search query when search controller changes', () {
        // Act
        controller.searchController.text = 'test search query';

        // Assert
        expect(controller.searchQuery.value, equals('test search query'));
      });

      test('should not add todo with empty title', () async {
        // Arrange
        controller.addTodoController.text = '';
        controller.addTodoDescriptionController.text = 'Some description';
        final initialCount = controller.todoList.length;

        // Act
        await controller.addTodo();

        // Assert
        expect(controller.todoList.length, equals(initialCount));
        expect(controller.isAddingTodo.value, equals(false));
      });

      test('should not add todo with whitespace-only title', () async {
        // Arrange
        controller.addTodoController.text = '   ';
        controller.addTodoDescriptionController.text = 'Some description';
        final initialCount = controller.todoList.length;

        // Act
        await controller.addTodo();

        // Assert
        expect(controller.todoList.length, equals(initialCount));
      });

      test('should prevent adding duplicate todos', () async {
        // Arrange
        const duplicateTitle = 'Duplicate Todo';
        final existingTodo =
            TestHelpers.createSampleTodo(title: duplicateTitle);
        controller.todoList.add(existingTodo);

        controller.addTodoController.text = duplicateTitle;
        controller.addTodoDescriptionController.text = 'Different description';
        final initialCount = controller.todoList.length;

        // Act
        await controller.addTodo();

        // Assert
        expect(controller.todoList.length, equals(initialCount));
        expect(controller.addTodoController.text, equals(duplicateTitle));
      });

      test('should not add todo when already adding', () async {
        // Arrange
        controller.isAddingTodo.value = true;
        controller.addTodoController.text = 'Test Todo';
        final initialCount = controller.todoList.length;

        // Act
        await controller.addTodo();

        // Assert
        expect(controller.todoList.length, equals(initialCount));
      });
    });

    group('Search and Filter Tests', () {
      setUp(() {
        // Add sample todos to the list
        controller.todoList.addAll([
          TestHelpers.createSampleTodo(
            id: '1',
            title: 'Flutter Development',
            description: 'Learn Flutter framework for mobile apps',
            priority: TodoPriority.high,
          ),
          TestHelpers.createSampleTodo(
            id: '2',
            title: 'Dart Programming',
            description: 'Master Dart language basics',
            priority: TodoPriority.medium,
          ),
          TestHelpers.createSampleTodo(
            id: '3',
            title: 'Unit Testing',
            description: 'Write comprehensive unit tests',
            priority: TodoPriority.low,
          ),
        ]);
      });

      test('should filter todos by title (case insensitive)', () {
        // Arrange
        controller.searchQuery.value = 'flutter';

        // Act
        final filtered = controller.filteredTodos;

        // Assert
        expect(filtered, hasLength(1));
        expect(filtered.first.title.toLowerCase(), contains('flutter'));
      });

      test('should filter todos by description', () {
        // Arrange
        controller.searchQuery.value = 'language';

        // Act
        final filtered = controller.filteredTodos;

        // Assert
        expect(filtered, hasLength(1));
        expect(filtered.first.description.toLowerCase(), contains('language'));
      });

      test('should be case insensitive in search', () {
        // Arrange
        controller.searchQuery.value = 'DART';

        // Act
        final filtered = controller.filteredTodos;

        // Assert
        expect(filtered, hasLength(1));
        expect(filtered.first.title.toLowerCase(), contains('dart'));
      });

      test('should return empty list when no matches found', () {
        // Arrange
        controller.searchQuery.value = 'nonexistent search term';

        // Act
        final filtered = controller.filteredTodos;

        // Assert
        expect(filtered, isEmpty);
      });

      test('should return all todos when search is empty', () {
        // Arrange
        controller.searchQuery.value = '';

        // Act
        final filtered = controller.filteredTodos;

        // Assert
        expect(filtered, hasLength(3));
      });

      test('should filter todos with partial matches', () {
        // Arrange
        controller.searchQuery.value = 'test';

        // Act
        final filtered = controller.filteredTodos;

        // Assert
        expect(filtered, hasLength(1)); // Should match "Unit Testing"
        expect(filtered.first.title, contains('Testing'));
      });
    });

    group('Sorting Tests', () {
      setUp(() {
        final now = DateTime.now();
        controller.todoList.clear();
        controller.todoList.addAll([
          TestHelpers.createSampleTodo(
            id: '1',
            title: 'Zebra Task',
            priority: TodoPriority.low,
            createdAt: now.subtract(const Duration(days: 1)),
            isCompleted: true,
          ),
          TestHelpers.createSampleTodo(
            id: '2',
            title: 'Alpha Task',
            priority: TodoPriority.urgent,
            createdAt: now,
            isCompleted: false,
          ),
          TestHelpers.createSampleTodo(
            id: '3',
            title: 'Beta Task',
            priority: TodoPriority.medium,
            createdAt: now.subtract(const Duration(hours: 12)),
            isCompleted: false,
          ),
        ]);
      });

      test('should sort by date created (newest first by default)', () {
        // Arrange
        controller.currentSortOption.value = TodoSortOption.dateCreated;
        controller.sortAscending.value = false; // Default

        // Act
        final sorted = controller.filteredTodos;

        // Assert
        expect(sorted[0].title, equals('Alpha Task')); // Most recent
        expect(sorted[1].title, equals('Beta Task')); // Middle
        expect(sorted[2].title, equals('Zebra Task')); // Oldest
      });

      test('should sort by date created (oldest first)', () {
        // Arrange
        controller.currentSortOption.value = TodoSortOption.dateCreated;
        controller.sortAscending.value = true;

        // Act
        final sorted = controller.filteredTodos;

        // Assert
        expect(sorted[0].title, equals('Zebra Task')); // Oldest
        expect(sorted[1].title, equals('Beta Task')); // Middle
        expect(sorted[2].title, equals('Alpha Task')); // Most recent
      });

      test('should sort by priority (highest first)', () {
        // Arrange
        controller.currentSortOption.value = TodoSortOption.priority;
        controller.sortAscending.value = false;

        // Act
        final sorted = controller.filteredTodos;

        // Assert
        expect(sorted[0].priority, equals(TodoPriority.urgent));
        expect(sorted[1].priority, equals(TodoPriority.medium));
        expect(sorted[2].priority, equals(TodoPriority.low));
      });

      test('should sort by priority (lowest first)', () {
        // Arrange
        controller.currentSortOption.value = TodoSortOption.priority;
        controller.sortAscending.value = true;

        // Act
        final sorted = controller.filteredTodos;

        // Assert
        expect(sorted[0].priority, equals(TodoPriority.low));
        expect(sorted[1].priority, equals(TodoPriority.medium));
        expect(sorted[2].priority, equals(TodoPriority.urgent));
      });

      test('should sort by title alphabetically (A-Z)', () {
        // Arrange
        controller.currentSortOption.value = TodoSortOption.title;
        controller.sortAscending.value = true;

        // Act
        final sorted = controller.filteredTodos;

        // Assert
        expect(sorted[0].title, equals('Alpha Task'));
        expect(sorted[1].title, equals('Beta Task'));
        expect(sorted[2].title, equals('Zebra Task'));
      });

      test('should sort by title alphabetically (Z-A)', () {
        // Arrange
        controller.currentSortOption.value = TodoSortOption.title;
        controller.sortAscending.value = false;

        // Act
        final sorted = controller.filteredTodos;

        // Assert
        expect(sorted[0].title, equals('Zebra Task'));
        expect(sorted[1].title, equals('Beta Task'));
        expect(sorted[2].title, equals('Alpha Task'));
      });

      test('should sort by completion status', () {
        // Arrange
        controller.currentSortOption.value = TodoSortOption.status;
        controller.sortAscending.value = true;

        // Act
        final sorted = controller.filteredTodos;

        // Assert - false (pending) comes before true (completed) alphabetically
        expect(sorted.where((todo) => !todo.isCompleted).length, equals(2));
        expect(sorted.where((todo) => todo.isCompleted).length, equals(1));
      });
    });

    group('Operation Loading States Tests', () {
      test('should track operation loading states correctly', () {
        // Arrange
        const operationKey = 'test-operation';

        // Initially should not be loading
        expect(controller.isOperationLoading(operationKey), isFalse);

        // Act - Set loading to true
        controller.operationLoadingStates[operationKey] = true;

        // Assert
        expect(controller.isOperationLoading(operationKey), isTrue);

        // Act - Set loading to false
        controller.operationLoadingStates[operationKey] = false;

        // Assert
        expect(controller.isOperationLoading(operationKey), isFalse);
      });

      test('should handle multiple operation loading states', () {
        // Arrange
        const operation1 = 'operation-1';
        const operation2 = 'operation-2';

        // Act
        controller.operationLoadingStates[operation1] = true;
        controller.operationLoadingStates[operation2] = false;

        // Assert
        expect(controller.isOperationLoading(operation1), isTrue);
        expect(controller.isOperationLoading(operation2), isFalse);
      });

      test('should return false for unknown operations', () {
        // Arrange
        const unknownOperation = 'unknown-operation';

        // Act & Assert
        expect(controller.isOperationLoading(unknownOperation), isFalse);
      });
    });

    group('Todo List Management Tests', () {
      test('should add todo to list', () {
        // Arrange
        final todo = TestHelpers.createSampleTodo();
        final initialCount = controller.todoList.length;

        // Act
        controller.todoList.add(todo);

        // Assert
        expect(controller.todoList.length, equals(initialCount + 1));
        expect(controller.todoList.contains(todo), isTrue);
      });

      test('should remove todo from list', () {
        // Arrange
        final todo = TestHelpers.createSampleTodo();
        controller.todoList.add(todo);
        final initialCount = controller.todoList.length;

        // Act
        controller.todoList.remove(todo);

        // Assert
        expect(controller.todoList.length, equals(initialCount - 1));
        expect(controller.todoList.contains(todo), isFalse);
      });

      test('should clear todo list', () {
        // Arrange
        controller.todoList.addAll(TestHelpers.createSampleTodos(5));
        expect(controller.todoList, isNotEmpty);

        // Act
        controller.todoList.clear();

        // Assert
        expect(controller.todoList, isEmpty);
      });

      test('should maintain reactive behavior when list changes', () {
        // Arrange
        final todo = TestHelpers.createSampleTodo();
        bool listChanged = false;

        // Listen to changes
        controller.todoList.listen((_) => listChanged = true);

        // Act
        controller.todoList.add(todo);

        // Assert
        expect(listChanged, isTrue);
      });
    });

    group('Priority Selection Tests', () {
      test('should update selected priority', () {
        // Arrange
        const newPriority = TodoPriority.urgent;

        // Act
        controller.selectedPriority.value = newPriority;

        // Assert
        expect(controller.selectedPriority.value, equals(newPriority));
      });

      test('should reset to medium priority when clearing form', () {
        // Arrange
        controller.selectedPriority.value = TodoPriority.high;

        // Act
        controller.clearAddTodoForm();

        // Assert
        expect(controller.selectedPriority.value, equals(TodoPriority.medium));
      });
    });

    group('Sort Option Tests', () {
      test('should change sort option', () {
        // Arrange
        const newSortOption = TodoSortOption.priority;

        // Act
        controller.currentSortOption.value = newSortOption;

        // Assert
        expect(controller.currentSortOption.value, equals(newSortOption));
      });

      test('should toggle sort direction', () {
        // Arrange
        expect(controller.sortAscending.value, isFalse); // Default

        // Act
        controller.sortAscending.value = true;

        // Assert
        expect(controller.sortAscending.value, isTrue);
      });

      test('should apply new sorting when option changes', () {
        // Arrange
        controller.todoList.addAll([
          TestHelpers.createSampleTodo(
              id: '1', title: 'Zebra', priority: TodoPriority.low),
          TestHelpers.createSampleTodo(
              id: '2', title: 'Alpha', priority: TodoPriority.high),
        ]);

        // Act - Sort by title ascending
        controller.currentSortOption.value = TodoSortOption.title;
        controller.sortAscending.value = true;
        final sortedByTitle = controller.filteredTodos;

        // Change to priority sorting
        controller.currentSortOption.value = TodoSortOption.priority;
        controller.sortAscending.value = false;
        final sortedByPriority = controller.filteredTodos;

        // Assert
        expect(sortedByTitle[0].title, equals('Alpha'));
        expect(sortedByTitle[1].title, equals('Zebra'));

        expect(sortedByPriority[0].priority, equals(TodoPriority.high));
        expect(sortedByPriority[1].priority, equals(TodoPriority.low));
      });
    });
  });
}
