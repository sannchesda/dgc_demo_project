#!/bin/bash

set -e  # Exit on any error

echo "Running local CI checks..."
echo

echo "1. Getting dependencies..."
flutter pub get

echo
echo "2. Checking code formatting..."
dart format --set-exit-if-changed .

echo
echo "3. Running static analysis..."
flutter analyze --fatal-infos

echo
echo "4. Running tests..."
echo "   Running model tests (no Firebase dependency)..."
flutter test test/models/
echo "   Running validation tests..."
flutter test test/validation/
echo "   Note: Skipping Firebase-dependent tests (controller, integration, widget tests)"
echo "   To run all tests, you need to mock Firebase first."

echo
echo "5. Building APK..."
flutter build apk --debug

echo
echo "6. Building iOS (no codesign)..."
flutter build ios --debug --no-codesign

echo
echo "All CI checks passed successfully!"
echo "You can now commit and push your changes."