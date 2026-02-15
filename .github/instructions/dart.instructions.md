---
applyTo: "**/*.dart"
description: "Dart development standards and best practices for the Rabbit Project"
---

# Dart Development Guidelines

Apply the [general coding guidelines](../copilot-instructions.md) to all Dart code.

## Language Standards

### Code Style
- Use `dart format` for consistent formatting
- Follow standard Dart naming conventions (camelCase, PascalCase, snake_case)
- Use meaningful and descriptive names for variables, functions, and classes
- Prefer explicit types when they improve readability
- Use trailing commas in parameter lists and collections

### Type Safety
- Leverage Dart's null safety features consistently
- Use late initialization only when necessary and document why
- Prefer non-nullable types by default
- Use nullable types ('?') only when values can genuinely be null
- Utilize pattern matching and sealed classes for exhaustive checking

### Memory Management
- Dispose of streams, controllers, and resources properly
- Use WeakReference for callback patterns to avoid memory leaks
- Close files, network connections, and other system resources
- Prefer immutable data structures where appropriate

### Error Handling
- Use Result types or custom exceptions for expected error cases
- Provide meaningful error messages that help debugging
- Handle platform exceptions appropriately in CLI applications
- Use assert statements for development-time checks

### Asynchronous Programming
- Prefer async/await over raw Futures and Streams
- Use StreamController carefully and dispose properly
- Handle potential exceptions in async operations
- Use Future.wait() for parallel operations when beneficial

## BLoC Pattern Standards

### State Management
- Use the BLoC pattern consistently across the application
- Keep BLoCs focused on single responsibilities
- Use Cubit for simple state management, BLoC for complex event handling
- Ensure BLoCs are properly closed to prevent memory leaks

### Event and State Design
- Make events and states immutable using copyWith patterns
- Use meaningful names that describe business actions, not UI actions
- Keep state classes small and focused
- Use sealed classes for state hierarchies when appropriate

## Package Development

### API Design
- Design clear and intuitive public APIs
- Use factory constructors for complex object creation
- Provide extension methods for enhancing existing types
- Follow the Principle of Least Surprise in API design

### Dependencies
- Minimize external dependencies in reusable packages
- Use dev_dependencies for build-time and test dependencies only
- Specify appropriate version constraints using semantic versioning
- Prefer well-maintained and popular packages from pub.dev

### Documentation
- Document all public APIs with clear dartdoc comments
- Include code examples in documentation
- Explain complex algorithms or business logic
- Keep README files updated with current usage examples

## CLI Application Standards

### Command Structure
- Use the args package for command-line argument parsing
- Provide helpful usage information and examples
- Support common flags like --help, --version, --verbose
- Use consistent naming conventions for commands and options

### User Experience
- Provide clear error messages with actionable suggestions
- Use progress indicators for long-running operations
- Support both interactive and non-interactive modes
- Handle common edge cases gracefully

### Terminal Integration
- Respect terminal capabilities and user preferences
- Use console colors appropriately and allow disabling
- Handle terminal resize events in TUI applications
- Provide keyboard shortcuts that follow common conventions

## Testing Guidelines

### Unit Testing
- Write tests for all public methods and functions
- Use descriptive test names that explain the expected behavior
- Follow the Arrange-Act-Assert pattern
- Mock external dependencies using proper mocking frameworks

### Test Organization
- Organize tests to mirror the source code structure
- Use group() to logically organize related tests
- Set up and tear down test environments properly
- Use test fixtures and helper functions to reduce duplication

### Integration Testing
- Test CLI commands end-to-end where practical
- Verify error handling and edge cases
- Test cross-package integration points
- Use golden file testing for stable text output

## Performance Considerations

- Use const constructors for immutable widgets and objects
- Prefer composition over inheritance for better performance
- Avoid excessive object creation in hot paths
- Use appropriate data structures for specific use cases
- Profile and measure before optimizing

## Security Practices

- Validate and sanitize all user inputs
- Use secure protocols for network communication
- Handle sensitive data appropriately (passwords, API keys)
- Follow least privilege principles in file and network access
- Keep dependencies updated to avoid known vulnerabilities