# dgc_demo_project

An assignment project for DGC recruitment

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Continuous Integration (CI)

This project includes a comprehensive CI/CD pipeline using GitHub Actions.

### CI Pipeline Features

- **Code Quality**: Automatic code formatting checks and static analysis
- **Testing**: Runs all unit tests, widget tests, and integration tests
- **Multi-platform Builds**: Builds for Android and iOS
- **Coverage Reports**: Generates and uploads code coverage to Codecov
- **Dependency Management**: Automated dependency updates via Dependabot

### CI Workflows

1. **Main CI Pipeline** (`.github/workflows/ci.yml`)
   - Triggers on push/PR to main/master/develop branches
   - Runs tests, linting, and builds for Android and iOS platforms

2. **Dependency Updates** (`.github/dependabot.yml`)
   - Weekly automated dependency updates
   - Covers both Dart/Flutter and Android dependencies

### Local CI Testing

Run the local CI script to test your changes before pushing:

```bash
# Windows
scripts\local_ci.bat

# macOS/Linux  
chmod +x scripts/local_ci.sh && ./scripts/local_ci.sh
```

**Note**: Currently runs model and validation tests only. Firebase-dependent tests (controllers, integration, widget tests) are skipped until Firebase mocking is implemented. See `FIREBASE_TEST_SETUP.md` for details.

### Setup Requirements

To fully utilize the CI pipeline, configure these GitHub secrets:

1. **CODECOV_TOKEN**: Codecov token (optional, for coverage reports)

### CI Status

[![CI](https://github.com/sannchesda/dgc_demo_project/actions/workflows/ci.yml/badge.svg)](https://github.com/sannchesda/dgc_demo_project/actions/workflows/ci.yml)
