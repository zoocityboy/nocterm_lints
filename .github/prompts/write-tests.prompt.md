---
mode: 'agent'
model: Grok Code Fast 1 (copilot)
tools: ['codebase', 'fileCreate', 'fileEdit']
description: 'Generate comprehensive tests for existing or new code'
---

# Write Tests Prompt

Your goal is to create comprehensive test coverage for the specified code components in the Rabbit Project.

## Test Types to Create

### Unit Tests
- Test individual functions, methods, and classes in isolation
- Use proper mocking for external dependencies
- Cover all code paths including error conditions
- Follow the Arrange-Act-Assert pattern
- Use descriptive test names that explain expected behavior

### BLoC/Cubit Tests
- Use bloc_test package for streamlined state testing
- Test all state transitions and event handling
- Verify initial states and error states
- Test side effects like API calls or navigation
- Mock all external dependencies and repositories

### Repository Tests
- Test data transformation and mapping logic
- Mock external services and APIs
- Test error handling and retry logic
- Verify caching behavior when implemented
- Test edge cases and boundary conditions

### CLI Command Tests
- Test command parsing and validation
- Verify output format and content
- Test error handling and user feedback
- Test both interactive and batch modes
- Mock external services and file system operations

### Service Tests
- Test business logic and workflow orchestration
- Mock all external dependencies
- Test error propagation and handling
- Verify resource cleanup and lifecycle management
- Test concurrent operations and thread safety

## Test Requirements

### Test Structure
- Organize tests to mirror source code structure
- Use group() to logically organize related tests
- Include proper setUp() and tearDown() methods
- Use meaningful test descriptions and group names
- Follow consistent naming conventions

### Test Data and Fixtures
- Create realistic test data that reflects actual usage
- Use factory methods or builders for complex test objects
- Keep test data minimal but meaningful
- Use const values for immutable test data
- Create shared fixtures for commonly used test objects

### Mocking Strategy
- Use mockito package for creating mocks
- Mock external services, APIs, and file system operations
- Verify mock interactions for side effects
- Use proper argument matchers for flexible mocking
- Reset mocks between tests to ensure isolation

### Coverage Goals
- Aim for high coverage on public APIs and critical paths
- Focus on testing behavior rather than implementation
- Cover error conditions and edge cases thoroughly
- Test both success and failure scenarios
- Include performance and resource usage tests where relevant

## Test Implementation Steps

1. **Analyze Code Structure**
   - Identify public APIs and critical logic to test
   - Understand dependencies and external interactions
   - Plan test organization and grouping strategy

2. **Create Test Infrastructure**
   - Set up test files with proper imports and structure
   - Create necessary mocks and test fixtures
   - Set up shared test utilities and helpers

3. **Implement Core Tests**
   - Write tests for main functionality and happy paths
   - Add comprehensive error handling tests
   - Include edge case and boundary condition tests

4. **Add Integration Tests**
   - Test component interactions and workflows
   - Verify proper data flow and transformations
   - Test CLI commands end-to-end where appropriate

5. **Verify Test Quality**
   - Ensure tests are fast, reliable, and maintainable
   - Verify tests fail when they should
   - Check test coverage and add missing tests
   - Review test readability and documentation

## Specific Test Patterns

### Async Testing
- Use proper async/await patterns in tests
- Test Future and Stream operations correctly
- Handle timeouts and cancellation appropriately
- Test error propagation in async operations

### File System Testing
- Use temporary directories for file operations
- Mock file system operations when appropriate
- Test file permission and access error handling
- Clean up test files and directories properly

### Network Testing
- Mock HTTP clients and WebSocket connections
- Test timeout and retry behavior
- Verify error handling for network failures
- Test with various response conditions

### State Management Testing
- Test state immutability and equality
- Verify proper state transitions and updates
- Test subscription and disposal behavior
- Mock time and async operations for deterministic tests

## Quality Standards

- All tests should pass consistently
- Tests should be fast and provide quick feedback
- Error messages should be clear and actionable
- Tests should be maintainable and easy to update
- Test code should follow the same quality standards as production code

Ask for clarification on which specific components or code areas need test coverage if not specified in the request.