---
mode: 'agent'
model: GPT-5 mini (copilot)
tools: ['codebase', 'fileEdit', 'search', 'usages']
description: 'Refactor existing code for improved quality, performance, or maintainability'
---

# Refactor Code Prompt

Your goal is to refactor existing code in the Rabbit Project to improve quality, performance, maintainability, or adherence to project standards.

## Refactoring Types

### Code Quality Refactoring
- Improve code readability and clarity
- Extract common patterns into reusable functions
- Simplify complex conditional logic
- Reduce code duplication and improve DRY principles
- Improve naming conventions and variable clarity

### Performance Refactoring
- Optimize algorithms and data structures
- Reduce memory allocations and improve resource usage
- Improve I/O operations and network efficiency
- Optimize hot code paths and critical performance areas
- Implement caching and memoization where appropriate

### Architectural Refactoring
- Improve separation of concerns and modularity
- Extract business logic into appropriate layers
- Implement proper dependency injection patterns
- Improve error handling and propagation
- Enhance testability through better design

### Pattern Implementation
- Migrate to established project patterns (BLoC, Repository, etc.)
- Implement missing abstraction layers
- Improve API design and consistency
- Extract common functionality into packages
- Implement proper state management patterns

## Refactoring Process

### 1. Analysis Phase
- **Identify Issues**: Use code analysis tools and manual review to identify areas needing improvement
- **Understand Context**: Review the purpose and usage patterns of the code being refactored
- **Plan Approach**: Determine the safest and most effective refactoring strategy
- **Assess Impact**: Understand dependencies and potential breaking changes

### 2. Preparation Phase
- **Create Tests**: Ensure comprehensive test coverage before refactoring
- **Document Current Behavior**: Record expected behavior and edge cases
- **Plan Migration**: For breaking changes, plan migration strategy and communication
- **Backup Strategy**: Ensure rollback plan exists for complex refactoring

### 3. Implementation Phase
- **Small Increments**: Make small, focused changes that can be easily reviewed
- **Preserve Behavior**: Ensure functionality remains identical unless explicitly changing behavior
- **Update Tests**: Modify tests to reflect new structure while maintaining coverage
- **Continuous Validation**: Run tests frequently during refactoring process

### 4. Validation Phase
- **Test Coverage**: Verify all tests pass and coverage remains adequate
- **Performance Testing**: Ensure performance improvements or no regressions
- **Integration Testing**: Verify integration with dependent components
- **Documentation Update**: Update documentation to reflect changes

## Common Refactoring Patterns

### Extract Function/Method
- Identify repeated code blocks or complex logic
- Extract into well-named functions with clear parameters
- Ensure single responsibility and clear purpose
- Add appropriate documentation and tests

### Extract Class/Service
- Identify cohesive functionality that can be grouped
- Create focused classes with clear responsibilities
- Implement proper interfaces and dependency injection
- Ensure proper lifecycle management and resource cleanup

### Improve Error Handling
- Replace generic error handling with specific error types
- Implement proper error propagation and recovery
- Add meaningful error messages and logging
- Ensure resource cleanup in error conditions

### Simplify Conditional Logic
- Replace complex if-else chains with polymorphism or strategy patterns
- Use early returns to reduce nesting levels
- Extract complex conditions into well-named boolean functions
- Implement exhaustive pattern matching where appropriate

### Optimize Data Structures
- Replace inefficient collections with appropriate alternatives
- Implement lazy evaluation where beneficial
- Use appropriate caching strategies
- Optimize memory usage and allocation patterns

## Dart-Specific Refactoring

### Null Safety Improvements
- Migrate legacy code to null safety patterns
- Use appropriate nullable types and null checks
- Implement proper null assertion and handling
- Use null-aware operators effectively

### Async/Await Optimization
- Convert callback-based code to async/await patterns
- Implement proper error handling in async operations
- Use appropriate stream and future composition
- Optimize concurrent operations and resource usage

### BLoC Pattern Refactoring
- Migrate stateful widgets to BLoC pattern
- Implement proper state and event hierarchies
- Optimize state transitions and performance
- Improve testability and separation of concerns

### Package Restructuring
- Extract reusable functionality into packages
- Improve package boundaries and dependencies
- Implement proper versioning and compatibility
- Optimize package size and dependency tree

## Quality Assurance

### Testing Strategy
- Maintain or improve test coverage during refactoring
- Update tests to reflect new structure and patterns
- Add tests for any new functionality or edge cases
- Ensure tests remain fast and maintainable

### Performance Verification
- Benchmark performance-critical changes
- Monitor memory usage and resource consumption
- Verify no performance regressions in hot paths
- Document performance improvements achieved

### Code Quality Metrics
- Verify code follows project standards and conventions
- Ensure documentation is complete and accurate
- Check that new code is more maintainable than original
- Validate that complexity has been reduced appropriately

## Communication and Documentation

### Change Documentation
- Document the purpose and benefits of the refactoring
- Explain any breaking changes and migration requirements
- Update relevant documentation and examples
- Communicate changes to affected team members

### Code Comments
- Update or add comments for complex logic changes
- Document any remaining technical debt or limitations
- Explain design decisions and trade-offs made
- Remove obsolete comments and documentation

## Risk Management

### Safety Measures
- Use feature flags for risky changes
- Implement gradual rollout for significant refactoring
- Monitor error rates and performance metrics after deployment
- Have rollback plan ready for unexpected issues

### Testing in Production
- Use canary releases for high-risk changes
- Monitor application behavior and user feedback
- Implement proper logging and monitoring for new code paths
- Be prepared to quickly address any issues discovered

Provide a clear refactoring plan with specific steps, rationale for changes, and verification strategy. Focus on improving code quality while maintaining or enhancing functionality and performance.