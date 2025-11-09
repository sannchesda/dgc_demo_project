import 'package:flutter_test/flutter_test.dart';
import 'package:dgc_demo_project/models/todo.dart';
import '../helpers/test_helpers.dart';

/// Simple CRUD simulation class for testing without Firebase dependency
class TodoListSimulator {
  final List<Todo> _todos = [];
  String _searchQuery = '';
  TodoSortOption _sortOption = TodoSortOption.dateCreated;
  bool _sortAscending = false;

  // CRUD Operations
  void addTodo(Todo todo) => _todos.add(todo);

  Todo? getTodoById(String id) => _todos.where((t) => t.id == id).isNotEmpty
      ? _todos.firstWhere((t) => t.id == id)
      : null;

  void updateTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
    if (index != -1) _todos[index] = updatedTodo;
  }

  bool deleteTodo(String id) {
    final initialLength = _todos.length;
    _todos.removeWhere((t) => t.id == id);
    return _todos.length < initialLength;
  }

  void clearAll() => _todos.clear();

  // Read operations with filtering and sorting
  List<Todo> get allTodos => List.from(_todos);

  List<Todo> get filteredTodos {
    List<Todo> filtered = List.from(_todos);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((todo) =>
              todo.title.toLowerCase().contains(query) ||
              todo.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case TodoSortOption.dateCreated:
        filtered.sort((a, b) => _sortAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case TodoSortOption.priority:
        filtered.sort((a, b) => _sortAscending
            ? a.priority.value.compareTo(b.priority.value)
            : b.priority.value.compareTo(a.priority.value));
        break;
      case TodoSortOption.title:
        filtered.sort((a, b) => _sortAscending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case TodoSortOption.status:
        filtered.sort((a, b) => _sortAscending
            ? a.isCompleted.toString().compareTo(b.isCompleted.toString())
            : b.isCompleted.toString().compareTo(a.isCompleted.toString()));
        break;
    }

    return filtered;
  }

  // Configuration
  void setSearchQuery(String query) => _searchQuery = query;
  void setSortOption(TodoSortOption option, bool ascending) {
    _sortOption = option;
    _sortAscending = ascending;
  }

  // Statistics
  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get pendingCount => _todos.where((t) => !t.isCompleted).length;
  double get completionPercentage =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount) * 100.0;
}

void main() {
  group('Todo CRUD Integration Tests (Firebase-Independent)', () {
    late TodoListSimulator todoList;

    setUp(() {
      todoList = TodoListSimulator();
    });

    group('Complete CRUD Workflow Tests', () {
      test('should perform complete Create-Read-Update-Delete workflow', () {
        // Initial state verification (Read - empty state)
        expect(todoList.allTodos, isEmpty);
        expect(todoList.filteredTodos, isEmpty);
        expect(todoList.totalCount, equals(0));

        // CREATE: Add a new todo
        final originalTodo = TestHelpers.createSampleTodo(
          id: 'workflow-test-1',
          title: 'Integration Test Todo',
          description: 'Testing complete CRUD workflow',
          priority: TodoPriority.medium,
          isCompleted: false,
        );

        todoList.addTodo(originalTodo);

        // READ: Verify todo was added
        expect(todoList.totalCount, equals(1));
        expect(todoList.allTodos, hasLength(1));
        final addedTodo = todoList.getTodoById('workflow-test-1');
        expect(addedTodo, isNotNull);
        expect(addedTodo!.title, equals('Integration Test Todo'));
        expect(addedTodo.isCompleted, isFalse);

        // UPDATE: Modify the todo
        final updatedTodo = originalTodo.copyWith(
          title: 'Updated Integration Test Todo',
          description: 'Updated description for testing',
          priority: TodoPriority.high,
          isCompleted: true,
        );

        todoList.updateTodo(updatedTodo);

        // READ: Verify update was successful
        expect(todoList.totalCount, equals(1));
        final retrievedTodo = todoList.getTodoById('workflow-test-1');
        expect(retrievedTodo, isNotNull);
        expect(retrievedTodo!.id, equals('workflow-test-1'));
        expect(retrievedTodo.title, equals('Updated Integration Test Todo'));
        expect(retrievedTodo.description,
            equals('Updated description for testing'));
        expect(retrievedTodo.priority, equals(TodoPriority.high));
        expect(retrievedTodo.isCompleted, isTrue);

        // DELETE: Remove the todo
        final deleteResult = todoList.deleteTodo('workflow-test-1');

        // READ: Verify deletion was successful
        expect(deleteResult, isTrue);
        expect(todoList.totalCount, equals(0));
        expect(todoList.allTodos, isEmpty);
        expect(todoList.filteredTodos, isEmpty);
        expect(todoList.getTodoById('workflow-test-1'), isNull);
      });

      test('should handle multiple todos in CRUD operations', () {
        // CREATE: Add multiple todos
        final todos = [
          TestHelpers.createSampleTodo(
            id: 'multi-1',
            title: 'First Todo',
            priority: TodoPriority.high,
          ),
          TestHelpers.createSampleTodo(
            id: 'multi-2',
            title: 'Second Todo',
            priority: TodoPriority.medium,
          ),
          TestHelpers.createSampleTodo(
            id: 'multi-3',
            title: 'Third Todo',
            priority: TodoPriority.low,
          ),
        ];

        for (final todo in todos) {
          todoList.addTodo(todo);
        }

        // READ: Verify all todos were added
        expect(todoList.totalCount, equals(3));
        expect(todoList.getTodoById('multi-1'), isNotNull);
        expect(todoList.getTodoById('multi-2'), isNotNull);
        expect(todoList.getTodoById('multi-3'), isNotNull);

        // UPDATE: Update specific todo
        final todoToUpdate = todoList.getTodoById('multi-2')!;
        final updatedTodo = todoToUpdate.copyWith(
          title: 'Updated Second Todo',
          isCompleted: true,
        );

        todoList.updateTodo(updatedTodo);

        // READ: Verify specific update
        final updated = todoList.getTodoById('multi-2');
        expect(updated!.title, equals('Updated Second Todo'));
        expect(updated.isCompleted, isTrue);

        // READ: Verify other todos unchanged
        expect(todoList.totalCount, equals(3));
        final firstTodo = todoList.getTodoById('multi-1');
        final thirdTodo = todoList.getTodoById('multi-3');
        expect(firstTodo!.title, equals('First Todo'));
        expect(thirdTodo!.title, equals('Third Todo'));

        // DELETE: Remove one todo
        final deleteResult = todoList.deleteTodo('multi-1');

        // READ: Verify partial deletion
        expect(deleteResult, isTrue);
        expect(todoList.totalCount, equals(2));
        expect(todoList.getTodoById('multi-1'), isNull);
        expect(todoList.getTodoById('multi-2'), isNotNull);
        expect(todoList.getTodoById('multi-3'), isNotNull);

        // DELETE: Clear all remaining todos
        todoList.clearAll();

        // READ: Verify complete deletion
        expect(todoList.totalCount, equals(0));
        expect(todoList.allTodos, isEmpty);
      });
    });

    group('CRUD with Search and Filter Integration', () {
      test('should maintain CRUD operations while filtering by search', () {
        // CREATE: Add sample todos
        final todos = [
          TestHelpers.createSampleTodo(
            id: 'search-1',
            title: 'Flutter Development Task',
            description: 'Learning Flutter framework',
          ),
          TestHelpers.createSampleTodo(
            id: 'search-2',
            title: 'Dart Programming Task',
            description: 'Mastering Dart language',
          ),
          TestHelpers.createSampleTodo(
            id: 'search-3',
            title: 'Testing Implementation',
            description: 'Writing unit tests for Flutter',
          ),
        ];

        for (final todo in todos) {
          todoList.addTodo(todo);
        }

        // READ: Verify all todos added
        expect(todoList.totalCount, equals(3));

        // SEARCH: Filter by 'Flutter'
        todoList.setSearchQuery('flutter');
        var filtered = todoList.filteredTodos;
        expect(filtered, hasLength(2)); // Should match 2 todos

        // CREATE: Add new todo while filtering
        final newTodo = TestHelpers.createSampleTodo(
          id: 'search-4',
          title: 'Flutter Widget Testing',
          description: 'Widget testing in Flutter apps',
        );
        todoList.addTodo(newTodo);

        // READ: Verify creation during filtering
        expect(todoList.totalCount, equals(4)); // All todos
        filtered = todoList.filteredTodos;
        expect(filtered, hasLength(3)); // Filtered todos matching 'flutter'

        // UPDATE: Update a filtered todo
        final todoToUpdate = todoList.getTodoById('search-1')!;
        final updatedTodo = todoToUpdate.copyWith(
          title: 'Advanced Flutter Development',
          isCompleted: true,
        );

        todoList.updateTodo(updatedTodo);

        // READ: Verify update during filtering
        filtered = todoList.filteredTodos;
        final updated = todoList.getTodoById('search-1')!;
        expect(updated.title, equals('Advanced Flutter Development'));
        expect(updated.isCompleted, isTrue);

        // DELETE: Remove a filtered todo
        final deleteResult = todoList.deleteTodo('search-3');

        // READ: Verify deletion during filtering
        expect(deleteResult, isTrue);
        expect(todoList.totalCount, equals(3)); // Total todos
        filtered = todoList.filteredTodos;
        expect(filtered, hasLength(2)); // Filtered todos after deletion

        // CLEAR SEARCH: Verify all operations persist
        todoList.setSearchQuery('');
        final allTodos = todoList.filteredTodos;
        expect(allTodos, hasLength(3));
        expect(todoList.getTodoById('search-3'),
            isNull); // Deleted todo not present
        expect(todoList.getTodoById('search-1')!.title,
            equals('Advanced Flutter Development')); // Update persisted
      });
    });

    group('CRUD with Sorting Integration', () {
      test('should maintain sorting during CRUD operations', () {
        final baseDate = DateTime.now();

        // CREATE: Add todos with different attributes for sorting
        final todos = [
          TestHelpers.createSampleTodo(
            id: 'sort-1',
            title: 'Zebra Task',
            priority: TodoPriority.low,
            createdAt: baseDate.subtract(const Duration(days: 2)),
          ),
          TestHelpers.createSampleTodo(
            id: 'sort-2',
            title: 'Alpha Task',
            priority: TodoPriority.high,
            createdAt: baseDate.subtract(const Duration(days: 1)),
          ),
          TestHelpers.createSampleTodo(
            id: 'sort-3',
            title: 'Beta Task',
            priority: TodoPriority.medium,
            createdAt: baseDate,
          ),
        ];

        for (final todo in todos) {
          todoList.addTodo(todo);
        }

        // Set sorting by title ascending
        todoList.setSortOption(TodoSortOption.title, true);

        // READ: Verify initial sorting
        var sorted = todoList.filteredTodos;
        expect(sorted[0].title, equals('Alpha Task'));
        expect(sorted[1].title, equals('Beta Task'));
        expect(sorted[2].title, equals('Zebra Task'));

        // CREATE: Add new todo during sorting
        final newTodo = TestHelpers.createSampleTodo(
          id: 'sort-4',
          title: 'Charlie Task',
          priority: TodoPriority.urgent,
          createdAt: baseDate.add(const Duration(hours: 1)),
        );
        todoList.addTodo(newTodo);

        // READ: Verify sorting maintained after addition
        sorted = todoList.filteredTodos;
        expect(sorted, hasLength(4));
        expect(sorted[0].title, equals('Alpha Task'));
        expect(sorted[1].title, equals('Beta Task'));
        expect(sorted[2].title, equals('Charlie Task'));
        expect(sorted[3].title, equals('Zebra Task'));

        // UPDATE: Change title that affects sorting
        final todoToUpdate = todoList.getTodoById('sort-2')!;
        final updatedTodo = todoToUpdate.copyWith(title: 'Yankee Task');

        todoList.updateTodo(updatedTodo);

        // READ: Verify sorting updated after title change
        sorted = todoList.filteredTodos;
        expect(sorted[0].title, equals('Beta Task'));
        expect(sorted[1].title, equals('Charlie Task'));
        expect(sorted[2].title, equals('Yankee Task')); // Moved to end
        expect(sorted[3].title, equals('Zebra Task'));

        // DELETE: Remove middle todo
        final deleteResult = todoList.deleteTodo('sort-4');

        // READ: Verify sorting maintained after deletion
        expect(deleteResult, isTrue);
        sorted = todoList.filteredTodos;
        expect(sorted, hasLength(3));
        expect(sorted[0].title, equals('Beta Task'));
        expect(sorted[1].title, equals('Yankee Task'));
        expect(sorted[2].title, equals('Zebra Task'));

        // CHANGE SORT: Switch to priority sorting (descending)
        todoList.setSortOption(TodoSortOption.priority, false);

        // READ: Verify new sorting applied to existing todos
        sorted = todoList.filteredTodos;
        expect(sorted[0].priority,
            equals(TodoPriority.high)); // Yankee Task (was Alpha Task)
        expect(sorted[1].priority, equals(TodoPriority.medium)); // Beta Task
        expect(sorted[2].priority, equals(TodoPriority.low)); // Zebra Task
      });
    });

    group('CRUD State Consistency Tests', () {
      test('should maintain state consistency during concurrent operations',
          () {
        // CREATE: Initial setup
        final initialTodos = TestHelpers.createSampleTodos(3);
        for (final todo in initialTodos) {
          todoList.addTodo(todo);
        }
        expect(todoList.totalCount, equals(3));

        // Simulate concurrent operations
        final originalCount = todoList.totalCount;

        // Multiple operations
        todoList.setSearchQuery('Todo 1');
        final filteredCount = todoList.filteredTodos.length;

        todoList.setSortOption(TodoSortOption.priority, true);

        // State consistency checks
        expect(todoList.totalCount,
            equals(originalCount)); // Original list unchanged
        expect(todoList.filteredTodos,
            hasLength(filteredCount)); // Filter still applied

        // Verify sorting is applied to filtered results
        final sortedFiltered = todoList.filteredTodos;
        if (sortedFiltered.length > 1) {
          for (int i = 0; i < sortedFiltered.length - 1; i++) {
            expect(sortedFiltered[i].priority.value,
                lessThanOrEqualTo(sortedFiltered[i + 1].priority.value));
          }
        }

        // Clear search and verify full list is properly sorted
        todoList.setSearchQuery('');
        final allSorted = todoList.filteredTodos;
        expect(allSorted, hasLength(originalCount));

        for (int i = 0; i < allSorted.length - 1; i++) {
          expect(allSorted[i].priority.value,
              lessThanOrEqualTo(allSorted[i + 1].priority.value));
        }
      });

      test('should handle edge cases in CRUD operations', () {
        // CREATE: Empty list operations
        expect(todoList.allTodos, isEmpty);
        expect(todoList.filteredTodos, isEmpty);
        expect(todoList.totalCount, equals(0));

        // DELETE from empty list (should not crash)
        final deleteFromEmpty = todoList.deleteTodo('non-existent');
        expect(deleteFromEmpty, isFalse);
        expect(todoList.totalCount, equals(0));

        // SEARCH in empty list
        todoList.setSearchQuery('search term');
        expect(todoList.filteredTodos, isEmpty);

        // CREATE: Add single todo
        final singleTodo = TestHelpers.createSampleTodo();
        todoList.addTodo(singleTodo);

        // READ: Single item operations
        expect(todoList.totalCount, equals(1));
        todoList.setSearchQuery(singleTodo.title);
        expect(todoList.filteredTodos, hasLength(1));

        // UPDATE: Single item
        final updated = singleTodo.copyWith(title: 'Updated Single Todo');
        todoList.updateTodo(updated);

        expect(todoList.totalCount, equals(1));
        expect(todoList.getTodoById(singleTodo.id)!.title,
            equals('Updated Single Todo'));

        // DELETE: Last item
        todoList.clearAll();
        expect(todoList.totalCount, equals(0));
        expect(todoList.filteredTodos, isEmpty);
      });
    });

    group('Performance and Scalability Tests', () {
      test('should handle large number of todos efficiently', () {
        // CREATE: Large dataset
        const largeCount = 1000;
        final largeTodoList = TestHelpers.createSampleTodos(largeCount);

        final stopwatch = Stopwatch()..start();
        for (final todo in largeTodoList) {
          todoList.addTodo(todo);
        }
        stopwatch.stop();

        // READ: Verify all added efficiently
        expect(todoList.totalCount, equals(largeCount));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast

        // SEARCH: Performance with large dataset
        stopwatch.reset();
        stopwatch.start();
        todoList.setSearchQuery('Todo 50');
        final searchResults = todoList.filteredTodos;
        stopwatch.stop();

        expect(searchResults, isNotEmpty);
        expect(stopwatch.elapsedMilliseconds,
            lessThan(500)); // Search should be fast

        // SORT: Performance with large dataset
        stopwatch.reset();
        stopwatch.start();
        todoList.setSortOption(TodoSortOption.title, true);
        final sortResults = todoList.filteredTodos;
        stopwatch.stop();

        expect(sortResults, isNotEmpty);
        expect(stopwatch.elapsedMilliseconds,
            lessThan(1000)); // Sort should be reasonably fast

        // UPDATE: Performance for bulk operations
        stopwatch.reset();
        stopwatch.start();

        // Update first 100 todos
        final todosToUpdate = todoList.allTodos.take(100).toList();
        for (final todo in todosToUpdate) {
          final updated = todo.copyWith(isCompleted: true);
          todoList.updateTodo(updated);
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds,
            lessThan(2000)); // Bulk update should be reasonable

        // DELETE: Performance for bulk deletion
        stopwatch.reset();
        stopwatch.start();
        todoList.clearAll();
        stopwatch.stop();

        expect(todoList.totalCount, equals(0));
        expect(stopwatch.elapsedMilliseconds,
            lessThan(100)); // Clear should be very fast
      });

      test('should track statistics correctly during CRUD operations', () {
        // Initial state
        expect(todoList.completionPercentage, equals(0.0));
        expect(todoList.completedCount, equals(0));
        expect(todoList.pendingCount, equals(0));

        // Add mixed completion todos
        final todos = [
          TestHelpers.createSampleTodo(id: '1', isCompleted: true),
          TestHelpers.createSampleTodo(id: '2', isCompleted: false),
          TestHelpers.createSampleTodo(id: '3', isCompleted: true),
          TestHelpers.createSampleTodo(id: '4', isCompleted: false),
        ];

        for (final todo in todos) {
          todoList.addTodo(todo);
        }

        // Verify statistics
        expect(todoList.totalCount, equals(4));
        expect(todoList.completedCount, equals(2));
        expect(todoList.pendingCount, equals(2));
        expect(todoList.completionPercentage, equals(50.0));

        // Complete one more todo
        final todoToComplete = todoList.getTodoById('2')!;
        todoList.updateTodo(todoToComplete.copyWith(isCompleted: true));

        // Verify updated statistics
        expect(todoList.completedCount, equals(3));
        expect(todoList.pendingCount, equals(1));
        expect(todoList.completionPercentage, equals(75.0));

        // Delete a completed todo
        todoList.deleteTodo('1');

        // Verify statistics after deletion
        expect(todoList.totalCount, equals(3));
        expect(todoList.completedCount, equals(2));
        expect(todoList.pendingCount, equals(1));
        expect(todoList.completionPercentage, closeTo(66.67, 0.01));
      });
    });
  });
}
