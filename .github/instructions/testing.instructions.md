---
applyTo: "**/test/**/*.dart"
description: "Testing standards and best practices for the Rabbit Project"
---

# Testing Guidelines

## Test Organization

### File Structure
- Mirror the source code structure in test directories
- Use the `_test.dart` suffix for all test files
- Group related tests in subdirectories when appropriate
- Keep test helpers in shared utilities

### Test Naming
- Use descriptive test names that explain expected behavior
- Follow the pattern: "should [expected behavior] when [condition]"
- Use group() to organize tests by feature or class
- Use meaningful group descriptions

## Unit Testing Standards

### Test Structure
- Follow Arrange-Act-Assert (AAA) pattern consistently
- Use setUp() and tearDown() for shared test preparation and cleanup
- Keep individual tests focused on single behaviors
- Avoid dependencies between tests

### Mocking and Stubs
- Mock external dependencies and services
- Use the mockito package for creating mocks
- Stub only the methods required for the specific test
- Verify mock interactions when testing side effects

### Test Data
- Use factory methods or test builders for creating test data
- Keep test data minimal and focused on the behavior being tested
- Use meaningful test data that reflects real-world scenarios
- Avoid hardcoded values that don't add clarity

## BLoC Testing

### State Testing
- Test all possible state transitions
- Verify initial states are correct
- Test state emissions in the correct order
- Use bloc_test for streamlined state testing

### Event Testing
- Test that events trigger expected state changes
- Verify side effects like API calls or navigation
- Test error handling for failed operations
- Test edge cases and invalid inputs

## CLI Testing

### Command Testing
- Test command parsing and validation
- Verify output format and content
- Test error handling and user feedback
- Test both interactive and non-interactive modes

### Integration Testing
- Test complete command workflows
- Verify file system interactions
- Test network operations with proper mocking
- Test terminal interactions and output formatting

## Test Coverage

### Coverage Goals
- Aim for high test coverage on public APIs
- Focus on critical business logic and edge cases
- Don't sacrifice test quality for coverage numbers
- Use coverage reports to identify untested code paths

### Coverage Tools
- Use the coverage package for generating reports
- Integrate coverage checking into CI/CD pipeline
- Set minimum coverage thresholds for packages
- Review coverage reports regularly

## Performance Testing

### Benchmarking
- Write benchmark tests for performance-critical code
- Use the benchmark_harness package for accurate measurements
- Test with realistic data sizes and scenarios
- Monitor performance regression in CI

### Load Testing
- Test CLI applications with large inputs
- Verify memory usage stays within acceptable bounds
- Test concurrent operations where applicable
- Profile and optimize based on actual usage patterns

## Test Maintenance

### Test Quality
- Keep tests simple and easy to understand
- Refactor tests when the code changes
- Remove obsolete tests promptly
- Update tests when requirements change

### Test Dependencies
- Keep test dependencies up to date
- Use dev_dependencies for test-only packages
- Avoid coupling tests to implementation details
- Make tests resilient to non-functional changes