import 'package:flutter_test/flutter_test.dart';
import 'package:dgc_demo_project/models/todo.dart';

void main() {
  group('Todo Model Tests', () {
    late DateTime testDate;
    late Map<String, dynamic> testMap;
    late Todo testTodo;

    setUp(() {
      testDate = DateTime(2023, 12, 25, 10, 30);
      testMap = {
        'title': 'Test Todo',
        'description': 'Test Description',
        'isCompleted': false,
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
        'priority': 'high',
      };
      testTodo = Todo(
        id: 'test-id',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: false,
        createdAt: testDate,
        updatedAt: testDate,
        priority: TodoPriority.high,
      );
    });

    group('Constructor Tests', () {
      test('should create Todo with required parameters', () {
        final todo = Todo(
          id: 'test-id',
          title: 'Test Title',
          isCompleted: false,
          createdAt: testDate,
        );

        expect(todo.id, equals('test-id'));
        expect(todo.title, equals('Test Title'));
        expect(todo.description, equals(''));
        expect(todo.isCompleted, equals(false));
        expect(todo.createdAt, equals(testDate));
        expect(todo.updatedAt, equals(testDate));
        expect(todo.priority, equals(TodoPriority.medium));
        expect(todo.status, equals(TodoStatus.viewing));
        expect(todo.draft, isNull);
      });

      test('should create Todo with all parameters', () {
        final customDate = DateTime(2023, 12, 26, 11, 45);
        final todo = Todo(
          id: 'test-id',
          title: 'Test Title',
          description: 'Test Description',
          isCompleted: true,
          createdAt: testDate,
          updatedAt: customDate,
          priority: TodoPriority.urgent,
          status: TodoStatus.editing,
          draft: 'Draft content',
        );

        expect(todo.id, equals('test-id'));
        expect(todo.title, equals('Test Title'));
        expect(todo.description, equals('Test Description'));
        expect(todo.isCompleted, equals(true));
        expect(todo.createdAt, equals(testDate));
        expect(todo.updatedAt, equals(customDate));
        expect(todo.priority, equals(TodoPriority.urgent));
        expect(todo.status, equals(TodoStatus.editing));
        expect(todo.draft, equals('Draft content'));
      });
    });

    group('Factory Constructor Tests', () {
      test('should create Todo from valid Map', () {
        final todo = Todo.fromMap(testMap, 'doc-id');

        expect(todo.id, equals('doc-id'));
        expect(todo.title, equals('Test Todo'));
        expect(todo.description, equals('Test Description'));
        expect(todo.isCompleted, equals(false));
        expect(todo.createdAt, equals(testDate));
        expect(todo.updatedAt, equals(testDate));
        expect(todo.priority, equals(TodoPriority.high));
        expect(todo.status, equals(TodoStatus.viewing));
      });

      test('should create Todo from Map with default values', () {
        final emptyMap = <String, dynamic>{};
        final todo = Todo.fromMap(emptyMap, 'doc-id');

        expect(todo.id, equals('doc-id'));
        expect(todo.title, equals(''));
        expect(todo.description, equals(''));
        expect(todo.isCompleted, equals(false));
        expect(todo.priority, equals(TodoPriority.medium));
        expect(todo.status, equals(TodoStatus.viewing));
        expect(todo.createdAt, isA<DateTime>());
        expect(todo.updatedAt, isA<DateTime>());
      });

      test('should handle invalid priority gracefully', () {
        final mapWithInvalidPriority = {
          ...testMap,
          'priority': 'invalid_priority',
        };
        final todo = Todo.fromMap(mapWithInvalidPriority, 'doc-id');

        expect(todo.priority, equals(TodoPriority.medium));
      });
    });

    group('toMap Tests', () {
      test('should convert Todo to Map correctly', () {
        final map = testTodo.toMap();

        expect(map['title'], equals('Test Todo'));
        expect(map['description'], equals('Test Description'));
        expect(map['isCompleted'], equals(false));
        expect(map['createdAt'], equals(testDate.toIso8601String()));
        expect(map['updatedAt'], equals(testDate.toIso8601String()));
        expect(map['priority'], equals('high'));
        expect(map.containsKey('id'), equals(false)); // ID should not be in map
      });
    });

    group('copyWith Tests', () {
      test(
          'should create copy with unchanged values when no parameters provided',
          () {
        final copy = testTodo.copyWith();

        expect(copy.id, equals(testTodo.id));
        expect(copy.title, equals(testTodo.title));
        expect(copy.description, equals(testTodo.description));
        expect(copy.isCompleted, equals(testTodo.isCompleted));
        expect(copy.createdAt, equals(testTodo.createdAt));
        expect(copy.priority, equals(testTodo.priority));
        expect(copy.status, equals(testTodo.status));
        expect(copy.draft, equals(testTodo.draft));
        // updatedAt should be set to now
        expect(copy.updatedAt, isNot(equals(testTodo.updatedAt)));
      });

      test('should create copy with updated values', () {
        final newDate = DateTime(2023, 12, 27, 15, 30);
        final copy = testTodo.copyWith(
          id: 'new-id',
          title: 'Updated Title',
          description: 'Updated Description',
          isCompleted: true,
          createdAt: newDate,
          updatedAt: newDate,
          priority: TodoPriority.low,
          status: TodoStatus.editing,
          draft: 'New draft',
        );

        expect(copy.id, equals('new-id'));
        expect(copy.title, equals('Updated Title'));
        expect(copy.description, equals('Updated Description'));
        expect(copy.isCompleted, equals(true));
        expect(copy.createdAt, equals(newDate));
        expect(copy.updatedAt, equals(newDate));
        expect(copy.priority, equals(TodoPriority.low));
        expect(copy.status, equals(TodoStatus.editing));
        expect(copy.draft, equals('New draft'));
      });

      test('should only update specified parameters', () {
        final copy = testTodo.copyWith(
          title: 'Only Title Changed',
          isCompleted: true,
        );

        expect(copy.title, equals('Only Title Changed'));
        expect(copy.isCompleted, equals(true));
        // Other values should remain the same
        expect(copy.id, equals(testTodo.id));
        expect(copy.description, equals(testTodo.description));
        expect(copy.createdAt, equals(testTodo.createdAt));
        expect(copy.priority, equals(testTodo.priority));
        expect(copy.status, equals(testTodo.status));
        expect(copy.draft, equals(testTodo.draft));
      });
    });

    group('Equality Tests', () {
      test('should be equal when IDs are the same', () {
        final todo1 = Todo(
          id: 'same-id',
          title: 'Title 1',
          isCompleted: false,
          createdAt: testDate,
        );
        final todo2 = Todo(
          id: 'same-id',
          title: 'Title 2',
          isCompleted: true,
          createdAt: testDate.add(const Duration(days: 1)),
        );

        expect(todo1, equals(todo2));
        expect(todo1.hashCode, equals(todo2.hashCode));
      });

      test('should not be equal when IDs are different', () {
        final todo1 = Todo(
          id: 'id-1',
          title: 'Same Title',
          isCompleted: false,
          createdAt: testDate,
        );
        final todo2 = Todo(
          id: 'id-2',
          title: 'Same Title',
          isCompleted: false,
          createdAt: testDate,
        );

        expect(todo1, isNot(equals(todo2)));
        expect(todo1.hashCode, isNot(equals(todo2.hashCode)));
      });

      test('should be identical to itself', () {
        expect(testTodo, equals(testTodo));
        expect(identical(testTodo, testTodo), isTrue);
      });

      test('should not be equal to different type', () {
        expect(testTodo == 'string', isFalse);
        expect(testTodo == 123, isFalse);
        // Testing with a different Todo object
        final differentTodo = Todo(
          id: 'different-id',
          title: 'Different Title',
          isCompleted: false,
          createdAt: testDate,
        );
        expect(testTodo == differentTodo, isFalse);
      });
    });

    group('toString Tests', () {
      test('should return formatted string representation', () {
        final todoString = testTodo.toString();

        expect(todoString, contains('Todo('));
        expect(todoString, contains('id: test-id'));
        expect(todoString, contains('title: Test Todo'));
        expect(todoString, contains('description: Test Description'));
        expect(todoString, contains('isCompleted: false'));
        expect(todoString, contains('priority: TodoPriority.high'));
      });
    });
  });

  group('TodoPriority Enum Tests', () {
    test('should have correct labels and values', () {
      expect(TodoPriority.low.label, equals('Low'));
      expect(TodoPriority.low.value, equals(1));

      expect(TodoPriority.medium.label, equals('Medium'));
      expect(TodoPriority.medium.value, equals(2));

      expect(TodoPriority.high.label, equals('High'));
      expect(TodoPriority.high.value, equals(3));

      expect(TodoPriority.urgent.label, equals('Urgent'));
      expect(TodoPriority.urgent.value, equals(4));
    });

    test('should have all values in correct order', () {
      final values = TodoPriority.values;
      expect(values, hasLength(4));
      expect(values[0], equals(TodoPriority.low));
      expect(values[1], equals(TodoPriority.medium));
      expect(values[2], equals(TodoPriority.high));
      expect(values[3], equals(TodoPriority.urgent));
    });
  });

  group('TodoStatus Enum Tests', () {
    test('should have correct values', () {
      final values = TodoStatus.values;
      expect(values, hasLength(2));
      expect(values, contains(TodoStatus.editing));
      expect(values, contains(TodoStatus.viewing));
    });
  });

  group('TodoSortOption Enum Tests', () {
    test('should have correct labels', () {
      expect(TodoSortOption.dateCreated.label, equals('Date Created'));
      expect(TodoSortOption.priority.label, equals('Priority'));
      expect(TodoSortOption.title.label, equals('Title'));
      expect(TodoSortOption.status.label, equals('Status'));
    });
  });

  group('LoadingState Enum Tests', () {
    test('should have all expected values', () {
      final values = LoadingState.values;
      expect(values, hasLength(3));
      expect(values, contains(LoadingState.loading));
      expect(values, contains(LoadingState.done));
      expect(values, contains(LoadingState.error));
    });
  });
}
