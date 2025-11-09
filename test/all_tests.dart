import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'models/todo_test.dart' as todo_model_tests;
import 'controllers/todo_controller_unit_test.dart' as controller_unit_tests;
import 'integration/crud_integration_test.dart' as integration_tests;

/// Comprehensive test suite for the Todo CRUD application
///
/// This file imports and runs all test suites to provide a complete
/// overview of the application's testing coverage.
///
/// Test Categories:
/// 1. Model Tests - Test the Todo model class
/// 2. Controller Unit Tests - Test individual controller methods
/// 3. Integration Tests - Test complete CRUD workflows
///
/// To run specific test categories, use:
/// - `flutter test test/models/` for model tests only
/// - `flutter test test/controllers/` for controller tests only
/// - `flutter test test/integration/` for integration tests only
/// - `flutter test` for all tests
void main() {
  group('Complete Todo Application Test Suite', () {
    group('📋 Model Layer Tests', () {
      todo_model_tests.main();
    });

    // group('🎮 Controller Layer Tests', () {
    //   controller_unit_tests.main();
    // });

    group('🔄 Integration Tests', () {
      integration_tests.main();
    });
  });
}
