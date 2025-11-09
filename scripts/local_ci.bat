@echo off
echo Running local CI checks...
echo.

echo 1. Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo Failed to get dependencies
    exit /b 1
)

echo.
echo 2. Checking code formatting...
call dart format --set-exit-if-changed .
if %errorlevel% neq 0 (
    echo Code formatting check failed
    exit /b 1
)

echo.
echo 3. Running static analysis...
call flutter analyze --fatal-infos
if %errorlevel% neq 0 (
    echo Static analysis failed
    exit /b 1
)

echo.
echo 4. Running tests...
echo    Running model tests (no Firebase dependency)...
call flutter test test\models\
if %errorlevel% neq 0 (
    echo Model tests failed
    exit /b 1
)
echo    Running validation tests...
call flutter test test\validation\
if %errorlevel% neq 0 (
    echo Validation tests failed
    exit /b 1
)
echo    Note: Skipping Firebase-dependent tests (controller, integration, widget tests)
echo    To run all tests, you need to mock Firebase first.

echo.
echo 5. Building APK (Debug Mode)...
call flutter build apk --debug
if %errorlevel% neq 0 (
    echo APK build failed
    exit /b 1
)

echo.
echo 6. Building iOS (Debug Mode, no codesign)...
call flutter build ios --debug --no-codesign
if %errorlevel% neq 0 (
    echo iOS build failed
    exit /b 1
)

echo.
echo All CI checks passed successfully!
echo You can now commit and push your changes.