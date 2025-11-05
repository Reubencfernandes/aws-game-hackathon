# Contributing to Flutter Chat App

Thank you for your interest in contributing to Flutter Chat App! This document provides guidelines and instructions for contributing.

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in Issues
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Environment details (OS, Flutter version, etc.)

### Suggesting Enhancements

1. Check existing issues and discussions
2. Create a new issue with:
   - Clear description of the enhancement
   - Use cases and benefits
   - Possible implementation approach

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow the code style guidelines below
   - Write/update tests for your changes
   - Update documentation as needed

4. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit your changes**
   ```bash
   git commit -m "feat: Add amazing feature"
   ```
   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `style:` Code style changes (formatting, etc.)
   - `refactor:` Code refactoring
   - `test:` Adding or updating tests
   - `chore:` Maintenance tasks

6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request**
   - Provide a clear description of the changes
   - Reference any related issues
   - Ensure all checks pass

## Code Style Guidelines

### General
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Format code with `flutter format .`

### Architecture
- Maintain clean architecture separation (domain, data, presentation)
- Keep business logic in use cases
- Use dependency injection via Riverpod providers
- Follow the existing patterns in the codebase

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants
- Private members: prefix with `_`

### Documentation
- Add dartdoc comments for public APIs
- Document complex logic
- Update README for user-facing changes

### Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Aim for high code coverage
- Mock external dependencies

## Project Structure

Follow the existing structure:
```
lib/
├── main.dart
└── src/
    ├── core/          # Shared utilities
    └── features/      # Feature modules
        └── feature_name/
            ├── data/
            ├── domain/
            └── presentation/
```

## Development Setup

1. Install Flutter 3.0+
2. Clone the repository
3. Run `flutter pub get`
4. Set up Firebase (see README)
5. Configure LLM endpoint
6. Run `flutter pub run build_runner build`

## Questions?

Feel free to open an issue for questions or reach out to maintainers.

Thank you for contributing! 🎉
