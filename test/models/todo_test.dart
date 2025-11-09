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
      test('should create Todo from valid Map with all fields', () {
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

      test('should create Todo from Map with minimal required fields', () {
        final minimalMap = {
          'title': 'Minimal Todo',
          'isCompleted': true,
        };
        final todo = Todo.fromMap(minimalMap, 'minimal-id');

        expect(todo.id, equals('minimal-id'));
        expect(todo.title, equals('Minimal Todo'));
        expect(todo.description, equals(''));
        expect(todo.isCompleted, equals(true));
        expect(todo.priority, equals(TodoPriority.medium));
        expect(todo.status, equals(TodoStatus.viewing));
        expect(todo.createdAt, isA<DateTime>());
        expect(todo.updatedAt, isA<DateTime>());
      });

      test('should create Todo from completely empty Map', () {
        final emptyMap = <String, dynamic>{};
        final todo = Todo.fromMap(emptyMap, 'empty-id');

        expect(todo.id, equals('empty-id'));
        expect(todo.title, equals(''));
        expect(todo.description, equals(''));
        expect(todo.isCompleted, equals(false));
        expect(todo.priority, equals(TodoPriority.medium));
        expect(todo.status, equals(TodoStatus.viewing));
        expect(todo.createdAt, isA<DateTime>());
        expect(todo.updatedAt, isA<DateTime>());
      });

      test('should handle all valid priority values correctly', () {
        for (final priority in TodoPriority.values) {
          final mapWithPriority = {
            'title': 'Priority Test',
            'priority': priority.name,
          };
          final todo = Todo.fromMap(mapWithPriority, 'priority-test-id');
          expect(todo.priority, equals(priority));
        }
      });

      test('should fallback to medium priority for invalid priority values',
          () {
        final invalidPriorityValues = [
          'invalid_priority',
          'URGENT', // Wrong case
          'super_high',
          null,
          123,
          [],
        ];

        for (final invalidPriority in invalidPriorityValues) {
          final mapWithInvalidPriority = {
            'title': 'Invalid Priority Test',
            'priority': invalidPriority,
          };
          final todo =
              Todo.fromMap(mapWithInvalidPriority, 'invalid-priority-id');
          expect(todo.priority, equals(TodoPriority.medium),
              reason: 'Failed for invalid priority: $invalidPriority');
        }
      });

      test('should handle malformed date strings gracefully', () {
        final mapWithInvalidDate = {
          'title': 'Date Test',
          'createdAt': 'invalid-date-string',
          'updatedAt': 'another-invalid-date',
        };

        expect(() => Todo.fromMap(mapWithInvalidDate, 'date-test-id'),
            throwsA(isA<FormatException>()));
      });

      test('should handle null date values by using current time', () {
        final mapWithNullDates = {
          'title': 'Null Date Test',
          'createdAt': null,
          'updatedAt': null,
        };
        final beforeCreation = DateTime.now();
        final todo = Todo.fromMap(mapWithNullDates, 'null-date-id');
        final afterCreation = DateTime.now();

        expect(
            todo.createdAt.isAfter(beforeCreation) ||
                todo.createdAt.isAtSameMomentAs(beforeCreation),
            isTrue);
        expect(
            todo.createdAt.isBefore(afterCreation) ||
                todo.createdAt.isAtSameMomentAs(afterCreation),
            isTrue);
        expect(
            todo.updatedAt.isAfter(beforeCreation) ||
                todo.updatedAt.isAtSameMomentAs(beforeCreation),
            isTrue);
        expect(
            todo.updatedAt.isBefore(afterCreation) ||
                todo.updatedAt.isAtSameMomentAs(afterCreation),
            isTrue);
      });
    });

    group('toMap Tests', () {
      test('should convert Todo to Map with all required fields', () {
        final map = testTodo.toMap();

        expect(map['title'], equals('Test Todo'));
        expect(map['description'], equals('Test Description'));
        expect(map['isCompleted'], equals(false));
        expect(map['createdAt'], equals(testDate.toIso8601String()));
        expect(map['updatedAt'], equals(testDate.toIso8601String()));
        expect(map['priority'], equals('high'));
        expect(map.containsKey('id'), equals(false)); // ID should not be in map
        expect(map.containsKey('status'),
            equals(false)); // Status should not be in map
        expect(map.containsKey('draft'),
            equals(false)); // Draft should not be in map
      });

      test('should handle all priority values in toMap conversion', () {
        for (final priority in TodoPriority.values) {
          final todo = testTodo.copyWith(priority: priority);
          final map = todo.toMap();
          expect(map['priority'], equals(priority.name));
        }
      });

      test('should convert empty strings correctly', () {
        final emptyTodo = Todo(
          id: 'empty-test',
          title: '',
          description: '',
          isCompleted: true,
          createdAt: testDate,
        );
        final map = emptyTodo.toMap();

        expect(map['title'], equals(''));
        expect(map['description'], equals(''));
        expect(map['isCompleted'], equals(true));
      });

      test('should produce valid Map for Firestore serialization', () {
        final map = testTodo.toMap();

        // Check all expected keys are present
        final expectedKeys = {
          'title',
          'description',
          'isCompleted',
          'createdAt',
          'updatedAt',
          'priority'
        };
        expect(map.keys.toSet(), equals(expectedKeys));

        // Check all values are serializable types
        for (final value in map.values) {
          expect(value is String || value is bool || value is num, isTrue,
              reason: 'All map values should be Firestore-compatible types');
        }
      });

      test('should handle edge case dates in toMap', () {
        final futureTodo = testTodo.copyWith(
          createdAt: DateTime(2030, 12, 31, 23, 59, 59),
          updatedAt: DateTime(2030, 12, 31, 23, 59, 59),
        );
        final map = futureTodo.toMap();

        expect(map['createdAt'], equals('2030-12-31T23:59:59.000'));
        expect(map['updatedAt'], equals('2030-12-31T23:59:59.000'));
      });
    });

    group('copyWith Tests', () {
      test(
          'should create copy with unchanged values when no parameters provided',
          () {
        final beforeCopy = DateTime.now();
        final copy = testTodo.copyWith();
        final afterCopy = DateTime.now();

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
        expect(
            copy.updatedAt.isAfter(beforeCopy) ||
                copy.updatedAt.isAtSameMomentAs(beforeCopy),
            isTrue);
        expect(
            copy.updatedAt.isBefore(afterCopy) ||
                copy.updatedAt.isAtSameMomentAs(afterCopy),
            isTrue);
      });

      test('should create copy with all parameters updated', () {
        final newDate = DateTime(2023, 12, 27, 15, 30);
        final copy = testTodo.copyWith(
          id: 'completely-new-id',
          title: 'Completely Updated Title',
          description: 'Completely Updated Description',
          isCompleted: true,
          createdAt: newDate,
          updatedAt: newDate,
          priority: TodoPriority.low,
          status: TodoStatus.editing,
          draft: 'New draft content',
        );

        expect(copy.id, equals('completely-new-id'));
        expect(copy.title, equals('Completely Updated Title'));
        expect(copy.description, equals('Completely Updated Description'));
        expect(copy.isCompleted, equals(true));
        expect(copy.createdAt, equals(newDate));
        expect(copy.updatedAt, equals(newDate));
        expect(copy.priority, equals(TodoPriority.low));
        expect(copy.status, equals(TodoStatus.editing));
        expect(copy.draft, equals('New draft content'));

        // Ensure original remains unchanged
        expect(testTodo.id, equals('test-id'));
        expect(testTodo.title, equals('Test Todo'));
        expect(testTodo.isCompleted, equals(false));
      });

      test('should update only specified single parameter', () {
        final titleCopy = testTodo.copyWith(title: 'Only Title Changed');
        expect(titleCopy.title, equals('Only Title Changed'));
        expect(titleCopy.description, equals(testTodo.description));
        expect(titleCopy.isCompleted, equals(testTodo.isCompleted));

        final statusCopy = testTodo.copyWith(isCompleted: true);
        expect(statusCopy.isCompleted, equals(true));
        expect(statusCopy.title, equals(testTodo.title));
        expect(statusCopy.description, equals(testTodo.description));

        final priorityCopy = testTodo.copyWith(priority: TodoPriority.urgent);
        expect(priorityCopy.priority, equals(TodoPriority.urgent));
        expect(priorityCopy.title, equals(testTodo.title));
        expect(priorityCopy.isCompleted, equals(testTodo.isCompleted));
      });

      test('should handle edge cases with empty and special strings', () {
        final copy = testTodo.copyWith(
          id: '',
          title: '',
          description: '',
          draft: '',
        );

        expect(copy.id, equals(''));
        expect(copy.title, equals(''));
        expect(copy.description, equals(''));
        expect(copy.draft, equals(''));
      });

      test('should handle draft parameter correctly', () {
        final todoWithDraft = testTodo.copyWith(draft: 'Some draft content');
        expect(todoWithDraft.draft, equals('Some draft content'));

        // Note: Current copyWith implementation uses ?? operator,
        // so passing null will preserve the existing draft value
        final copyWithNullDraft = todoWithDraft.copyWith(draft: null);
        expect(copyWithNullDraft.draft, equals('Some draft content'));

        // To clear the draft, pass an empty string
        final copyWithEmptyDraft = todoWithDraft.copyWith(draft: '');
        expect(copyWithEmptyDraft.draft, equals(''));
      });

      test('should preserve immutability of original Todo', () {
        final originalId = testTodo.id;
        final originalTitle = testTodo.title;
        final originalCompleted = testTodo.isCompleted;

        testTodo.copyWith(
          id: 'modified-id',
          title: 'Modified Title',
          isCompleted: !testTodo.isCompleted,
        );

        // Original should remain unchanged
        expect(testTodo.id, equals(originalId));
        expect(testTodo.title, equals(originalTitle));
        expect(testTodo.isCompleted, equals(originalCompleted));
      });

      test('should handle all priority and status enum values', () {
        for (final priority in TodoPriority.values) {
          final copy = testTodo.copyWith(priority: priority);
          expect(copy.priority, equals(priority));
        }

        for (final status in TodoStatus.values) {
          final copy = testTodo.copyWith(status: status);
          expect(copy.status, equals(status));
        }
      });
    });

    group('Equality Tests', () {
      test('should be equal for identical Todo objects with same ID', () {
        final todo1 = Todo(
          id: 'same-id',
          title: 'Original Title',
          description: 'Original Description',
          isCompleted: false,
          createdAt: testDate,
          priority: TodoPriority.low,
        );
        final todo2 = Todo(
          id: 'same-id',
          title: 'Different Title',
          description: 'Different Description',
          isCompleted: true,
          createdAt: testDate.add(const Duration(days: 1)),
          priority: TodoPriority.urgent,
        );

        expect(todo1, equals(todo2));
        expect(todo1.hashCode, equals(todo2.hashCode));
      });

      test('should not be equal when IDs are different', () {
        final todo1 = Todo(
          id: 'id-1',
          title: 'Identical Title',
          description: 'Identical Description',
          isCompleted: false,
          createdAt: testDate,
          priority: TodoPriority.medium,
        );
        final todo2 = Todo(
          id: 'id-2',
          title: 'Identical Title',
          description: 'Identical Description',
          isCompleted: false,
          createdAt: testDate,
          priority: TodoPriority.medium,
        );

        expect(todo1, isNot(equals(todo2)));
        expect(todo1.hashCode, isNot(equals(todo2.hashCode)));
      });

      test('should be identical to itself (reflexive property)', () {
        expect(testTodo, equals(testTodo));
        expect(identical(testTodo, testTodo), isTrue);
      });

      test('should maintain equality consistency across multiple calls', () {
        final todo1 = Todo(
          id: 'consistent-id',
          title: 'Test Todo',
          isCompleted: false,
          createdAt: testDate,
        );
        final todo2 = Todo(
          id: 'consistent-id',
          title: 'Different Title',
          isCompleted: true,
          createdAt: testDate.add(const Duration(hours: 5)),
        );

        // Multiple equality checks should return consistent results
        expect(todo1 == todo2, isTrue);
        expect(todo1 == todo2, isTrue);
        expect(todo2 == todo1, isTrue); // Symmetric property
        expect(todo1.hashCode == todo2.hashCode, isTrue);
      });

      test('should handle edge cases with empty and special characters in ID',
          () {
        final todo1 = Todo(
          id: 'special@#\$%^&*()_+-={}[]|\\:";\'<>?,./',
          title: 'Special ID Test',
          isCompleted: false,
          createdAt: testDate,
        );
        final todo2 = Todo(
          id: 'special@#\$%^&*()_+-={}[]|\\:";\'<>?,./',
          title: 'Different Title',
          isCompleted: true,
          createdAt: testDate,
        );

        expect(todo1, equals(todo2));
      });

      test('should handle Unicode characters in ID', () {
        final todo1 = Todo(
          id: '测试-тест-テスト-🚀',
          title: 'Unicode ID Test',
          isCompleted: false,
          createdAt: testDate,
        );
        final todo2 = Todo(
          id: '测试-тест-テスト-🚀',
          title: 'Different Title',
          isCompleted: true,
          createdAt: testDate,
        );

        expect(todo1, equals(todo2));
        expect(todo1.hashCode, equals(todo2.hashCode));
      });
    });

    group('toString Tests', () {
      test('should return formatted string representation with all fields', () {
        final todoString = testTodo.toString();

        expect(todoString, startsWith('Todo('));
        expect(todoString, endsWith(')'));
        expect(todoString, contains('id: test-id'));
        expect(todoString, contains('title: Test Todo'));
        expect(todoString, contains('description: Test Description'));
        expect(todoString, contains('isCompleted: false'));
        expect(todoString, contains('priority: TodoPriority.high'));
        expect(todoString, contains('createdAt: $testDate'));
        expect(todoString, contains('updatedAt: $testDate'));
        expect(todoString, contains('status: TodoStatus.viewing'));
        expect(todoString, contains('draft: null'));
      });

      test('should handle special characters in toString', () {
        final specialTodo = testTodo.copyWith(
          id: r'special@#$%^&*()',
          title: 'Special "Quotes" & Symbols',
          description: 'Line1\nLine2\tTabbed',
          draft: 'Draft with \n newlines and \t tabs',
        );
        final todoString = specialTodo.toString();

        expect(todoString, contains(r'id: special@#$%^&*()'));
        expect(todoString, contains('title: Special "Quotes" & Symbols'));
        expect(todoString, contains('description: Line1\nLine2\tTabbed'));
        expect(
            todoString, contains('draft: Draft with \n newlines and \t tabs'));
      });

      test('should be consistent across multiple calls', () {
        final firstCall = testTodo.toString();
        final secondCall = testTodo.toString();

        expect(firstCall, equals(secondCall));
      });

      test('should handle empty strings appropriately', () {
        final emptyTodo = testTodo.copyWith(
          title: '',
          description: '',
          draft: '',
        );
        final todoString = emptyTodo.toString();

        expect(todoString, contains('title: '));
        expect(todoString, contains('description: '));
        expect(todoString, contains('draft: '));
      });

      test('should differentiate between null and empty draft', () {
        final nullDraftTodo = testTodo.copyWith(draft: null);
        final emptyDraftTodo = testTodo.copyWith(draft: '');

        expect(nullDraftTodo.toString(), contains('draft: null'));
        expect(emptyDraftTodo.toString(), contains('draft: '));
        expect(
            nullDraftTodo.toString(), isNot(equals(emptyDraftTodo.toString())));
      });
    });
  });

  group('TodoPriority Enum Tests', () {
    test('should have correct labels and values for all priorities', () {
      expect(TodoPriority.low.label, equals('Low'));
      expect(TodoPriority.low.value, equals(1));
      expect(TodoPriority.low.name, equals('low'));

      expect(TodoPriority.medium.label, equals('Medium'));
      expect(TodoPriority.medium.value, equals(2));
      expect(TodoPriority.medium.name, equals('medium'));

      expect(TodoPriority.high.label, equals('High'));
      expect(TodoPriority.high.value, equals(3));
      expect(TodoPriority.high.name, equals('high'));

      expect(TodoPriority.urgent.label, equals('Urgent'));
      expect(TodoPriority.urgent.value, equals(4));
      expect(TodoPriority.urgent.name, equals('urgent'));
    });

    test('should maintain correct priority hierarchy (ascending values)', () {
      final priorities = TodoPriority.values;
      for (int i = 1; i < priorities.length; i++) {
        expect(priorities[i].value, greaterThan(priorities[i - 1].value),
            reason:
                '${priorities[i].name} should have higher value than ${priorities[i - 1].name}');
      }
    });

    test('should have all values in correct order', () {
      final values = TodoPriority.values;
      expect(values, hasLength(4));
      expect(values[0], equals(TodoPriority.low));
      expect(values[1], equals(TodoPriority.medium));
      expect(values[2], equals(TodoPriority.high));
      expect(values[3], equals(TodoPriority.urgent));
    });

    test('should have unique values for each priority', () {
      final values = TodoPriority.values.map((p) => p.value).toSet();
      expect(values, hasLength(TodoPriority.values.length),
          reason: 'All priority values should be unique');
    });

    test('should have unique names for each priority', () {
      final names = TodoPriority.values.map((p) => p.name).toSet();
      expect(names, hasLength(TodoPriority.values.length),
          reason: 'All priority names should be unique');
    });
  });

  group('TodoStatus Enum Tests', () {
    test('should have exactly two status values', () {
      final values = TodoStatus.values;
      expect(values, hasLength(2));
      expect(values, contains(TodoStatus.editing));
      expect(values, contains(TodoStatus.viewing));
    });

    test('should have correct enum names', () {
      expect(TodoStatus.editing.name, equals('editing'));
      expect(TodoStatus.viewing.name, equals('viewing'));
    });

    test('should be usable in switches without warnings', () {
      // Test that all enum values are covered
      String getStatusDescription(TodoStatus status) {
        switch (status) {
          case TodoStatus.editing:
            return 'Currently editing';
          case TodoStatus.viewing:
            return 'Currently viewing';
        }
      }

      expect(getStatusDescription(TodoStatus.editing),
          equals('Currently editing'));
      expect(getStatusDescription(TodoStatus.viewing),
          equals('Currently viewing'));
    });
  });

  group('TodoSortOption Enum Tests', () {
    test('should have correct labels for all sort options', () {
      expect(TodoSortOption.dateCreated.label, equals('Date Created'));
      expect(TodoSortOption.dateCreated.name, equals('dateCreated'));

      expect(TodoSortOption.priority.label, equals('Priority'));
      expect(TodoSortOption.priority.name, equals('priority'));

      expect(TodoSortOption.title.label, equals('Title'));
      expect(TodoSortOption.title.name, equals('title'));

      expect(TodoSortOption.status.label, equals('Status'));
      expect(TodoSortOption.status.name, equals('status'));
    });

    test('should have all expected sort options', () {
      final values = TodoSortOption.values;
      expect(values, hasLength(4));
      expect(values, contains(TodoSortOption.dateCreated));
      expect(values, contains(TodoSortOption.priority));
      expect(values, contains(TodoSortOption.title));
      expect(values, contains(TodoSortOption.status));
    });

    test('should have unique labels for all sort options', () {
      final labels =
          TodoSortOption.values.map((option) => option.label).toSet();
      expect(labels, hasLength(TodoSortOption.values.length),
          reason: 'All sort option labels should be unique');
    });
  });

  group('LoadingState Enum Tests', () {
    test('should have all expected loading states', () {
      final values = LoadingState.values;
      expect(values, hasLength(3));
      expect(values, contains(LoadingState.loading));
      expect(values, contains(LoadingState.done));
      expect(values, contains(LoadingState.error));
    });

    test('should have correct enum names', () {
      expect(LoadingState.loading.name, equals('loading'));
      expect(LoadingState.done.name, equals('done'));
      expect(LoadingState.error.name, equals('error'));
    });

    test('should be usable for state management logic', () {
      // Test typical loading state transitions
      bool isLoading(LoadingState state) => state == LoadingState.loading;
      bool isComplete(LoadingState state) => state == LoadingState.done;
      bool hasError(LoadingState state) => state == LoadingState.error;

      expect(isLoading(LoadingState.loading), isTrue);
      expect(isLoading(LoadingState.done), isFalse);
      expect(isLoading(LoadingState.error), isFalse);

      expect(isComplete(LoadingState.done), isTrue);
      expect(isComplete(LoadingState.loading), isFalse);
      expect(isComplete(LoadingState.error), isFalse);

      expect(hasError(LoadingState.error), isTrue);
      expect(hasError(LoadingState.loading), isFalse);
      expect(hasError(LoadingState.done), isFalse);
    });
  });
}
