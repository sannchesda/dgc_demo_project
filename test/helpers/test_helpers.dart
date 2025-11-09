import 'package:dgc_demo_project/models/todo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class TestHelpers {
  /// Creates a sample Todo for testing
  static Todo createSampleTodo({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    TodoPriority? priority,
    TodoStatus? status,
    String? draft,
  }) {
    final now = DateTime.now();
    return Todo(
      id: id ?? 'test-id-123',
      title: title ?? 'Sample Todo',
      description: description ?? 'Sample Description',
      isCompleted: isCompleted ?? false,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      priority: priority ?? TodoPriority.medium,
      status: status ?? TodoStatus.viewing,
      draft: draft,
    );
  }

  /// Creates multiple sample todos for testing
  static List<Todo> createSampleTodos(int count) {
    return List.generate(count, (index) {
      final now = DateTime.now().add(Duration(minutes: index));
      return createSampleTodo(
        id: 'test-id-$index',
        title: 'Todo ${index + 1}',
        description: 'Description ${index + 1}',
        createdAt: now,
        priority: TodoPriority.values[index % TodoPriority.values.length],
        isCompleted: index % 2 == 0,
      );
    });
  }

  /// Creates a Map representation of a Todo for Firestore testing
  static Map<String, dynamic> createTodoMap({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? priority,
  }) {
    final now = DateTime.now();
    return {
      'title': title ?? 'Test Todo',
      'description': description ?? 'Test Description',
      'isCompleted': isCompleted ?? false,
      'createdAt': (createdAt ?? now).toIso8601String(),
      'updatedAt': (updatedAt ?? now).toIso8601String(),
      'priority': priority ?? 'medium',
    };
  }

  /// Cleans up GetX controllers and dependencies
  static void cleanupGetX() {
    Get.reset();
  }

  /// Sets up GetX for testing
  static void setupGetX() {
    Get.testMode = true;
  }

  /// Creates a test date that's consistent across tests
  static DateTime get testDate => DateTime(2023, 12, 25, 10, 30);

  /// Creates a future date for testing
  static DateTime get futureDateDate => DateTime(2024, 1, 15, 14, 30);

  /// Creates a past date for testing
  static DateTime get pastDate => DateTime(2023, 11, 15, 8, 15);
}

/// Mock data constants for consistent testing
class MockData {
  static const String sampleTitle = 'Sample Todo Title';
  static const String sampleDescription =
      'This is a sample todo description for testing purposes.';
  static const String sampleId = 'sample-todo-id-123';
  static const String updatedTitle = 'Updated Todo Title';
  static const String updatedDescription = 'This is an updated description.';

  static const String longTitle =
      'This is a very long todo title that might be used to test text wrapping and display limits in the UI components of the application';
  static const String longDescription =
      'This is an extremely long description that contains multiple sentences and might be used to test how the application handles large amounts of text in the description field. It includes various punctuation marks, numbers like 123, and special characters like @, #, \$, %, and &. This helps ensure the application can handle diverse input properly.';

  static const String emptyString = '';
  static const String whitespaceString = '   ';
  static const String specialCharacters = '!@#\$%^&*()_+-=[]{}|;:\'",./<>?`~';

  static Todo get sampleTodo => TestHelpers.createSampleTodo(
        id: sampleId,
        title: sampleTitle,
        description: sampleDescription,
      );

  static List<Todo> get multipleTodos => [
        TestHelpers.createSampleTodo(
          id: 'todo-1',
          title: 'First Todo',
          description: 'First description',
          priority: TodoPriority.high,
          isCompleted: false,
        ),
        TestHelpers.createSampleTodo(
          id: 'todo-2',
          title: 'Second Todo',
          description: 'Second description',
          priority: TodoPriority.low,
          isCompleted: true,
        ),
        TestHelpers.createSampleTodo(
          id: 'todo-3',
          title: 'Third Todo',
          description: 'Third description',
          priority: TodoPriority.urgent,
          isCompleted: false,
        ),
      ];
}

/// Custom matchers for testing
class TodoMatchers {
  /// Matches a Todo with specific properties
  static Matcher todoWithTitle(String expectedTitle) {
    return predicate<Todo>((todo) => todo.title == expectedTitle,
        'Todo with title "$expectedTitle"');
  }

  /// Matches a completed Todo
  static Matcher get completedTodo {
    return predicate<Todo>(
        (todo) => todo.isCompleted, 'Todo that is completed');
  }

  /// Matches a pending Todo
  static Matcher get pendingTodo {
    return predicate<Todo>((todo) => !todo.isCompleted, 'Todo that is pending');
  }

  /// Matches a Todo with specific priority
  static Matcher todoWithPriority(TodoPriority expectedPriority) {
    return predicate<Todo>((todo) => todo.priority == expectedPriority,
        'Todo with priority "${expectedPriority.label}"');
  }

  /// Matches a Todo in editing status
  static Matcher get editingTodo {
    return predicate<Todo>(
        (todo) => todo.status == TodoStatus.editing, 'Todo in editing status');
  }

  /// Matches a Todo in viewing status
  static Matcher get viewingTodo {
    return predicate<Todo>(
        (todo) => todo.status == TodoStatus.viewing, 'Todo in viewing status');
  }
}

/// Test group helpers for organizing tests
class TestGroups {
  /// Runs a test group with GetX setup and teardown
  static void groupWithGetX(String description, dynamic Function() body) {
    group(description, () {
      setUp(() {
        TestHelpers.setupGetX();
      });

      tearDown(() {
        TestHelpers.cleanupGetX();
      });

      body();
    });
  }

  /// Runs a test with automatic setup and cleanup
  static void testWithSetup(
    String description,
    Future<void> Function() testBody, {
    Future<void> Function()? setUp,
    Future<void> Function()? tearDown,
  }) {
    test(description, () async {
      if (setUp != null) await setUp();

      try {
        await testBody();
      } finally {
        if (tearDown != null) await tearDown();
      }
    });
  }
}

/// Exception helpers for testing error scenarios
class TestExceptions {
  static Exception get networkException => Exception('Network error occurred');
  static Exception get firestoreException =>
      Exception('Firestore operation failed');
  static Exception get validationException => Exception('Validation failed');
  static Exception get permissionException => Exception('Permission denied');
}

/// Performance testing helpers
class PerformanceHelpers {
  /// Measures the execution time of a function
  static Future<Duration> measureExecutionTime(
      Future<void> Function() function) async {
    final stopwatch = Stopwatch()..start();
    await function();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Verifies that a function completes within a specified time
  static Future<void> expectCompletesWithin(
    Duration maxDuration,
    Future<void> Function() function,
  ) async {
    final executionTime = await measureExecutionTime(function);
    expect(executionTime, lessThanOrEqualTo(maxDuration));
  }
}
