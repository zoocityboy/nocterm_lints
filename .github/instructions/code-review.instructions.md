---
applyTo: "**/*.dart"
description: "Code review standards and guidelines for the Rabbit Project"
---

# Code Review Guidelines

## Review Scope and Focus

### Code Quality
- Verify code follows established Dart conventions and project standards
- Check for proper error handling and edge case coverage
- Review algorithmic efficiency and performance considerations
- Ensure code is readable, maintainable, and well-documented
- Validate that public APIs are well-designed and consistent

### Architecture and Design
- Review adherence to established architectural patterns
- Verify proper separation of concerns and modularity
- Check for appropriate abstraction levels and interfaces
- Ensure new code integrates well with existing codebase
- Validate design decisions align with project goals

## Testing Requirements

### Test Coverage
- Verify comprehensive test coverage for new functionality
- Check that tests are meaningful and test actual behavior
- Ensure edge cases and error conditions are tested
- Review test structure and organization for clarity
- Validate that tests are fast, reliable, and maintainable

### Test Quality
- Review test names and descriptions for clarity
- Check that tests are isolated and don't depend on each other
- Verify proper use of mocks and test doubles
- Ensure tests fail when they should and pass when expected
- Review async test handling and timing considerations

## Security Review

### Security Considerations
- Review input validation and sanitization
- Check for potential security vulnerabilities
- Verify proper handling of sensitive data and credentials
- Review network security and API usage
- Ensure appropriate access controls and permissions

### Dependency Security
- Review new dependencies for security implications
- Check for known vulnerabilities in updated packages
- Verify dependency versions and update policies
- Review third-party code integration security
- Ensure minimal privilege principles are followed

## Performance Review

### Performance Impact
- Review changes for potential performance regressions
- Check memory usage and resource management
- Verify efficient algorithms and data structure usage
- Review I/O operations and network efficiency
- Assess scalability implications of changes

### Monitoring and Measurement
- Verify performance-critical changes include benchmarks
- Check that appropriate logging and monitoring is in place
- Review error handling performance impact
- Ensure performance assumptions are documented
- Validate performance testing coverage

## Documentation Review

### Code Documentation
- Verify public APIs are properly documented
- Check for clear and helpful inline comments
- Review dartdoc quality and completeness
- Ensure complex logic is well-explained
- Validate that documentation matches implementation

### Project Documentation
- Review updates to README files and user guides
- Check changelog entries for accuracy and completeness
- Verify example code is current and functional
- Review migration guides for breaking changes
- Ensure documentation is accessible and well-organized

## Application-Specific Reviews

### CLI Application Changes
- Review command-line interface consistency and usability
- Check help text and error message quality
- Verify proper handling of user input and edge cases
- Review terminal compatibility and output formatting
- Ensure backward compatibility where appropriate

### Package Development
- Review public API design and backward compatibility
- Check package metadata and version constraints
- Verify example code and documentation quality
- Review dependency management and isolation
- Ensure proper semantic versioning practices

## Review Process

### Review Checklist
- [ ] Code follows project coding standards and conventions
- [ ] Tests are comprehensive and well-structured
- [ ] Documentation is complete and accurate
- [ ] Security considerations have been addressed
- [ ] Performance impact has been evaluated
- [ ] Breaking changes are properly documented
- [ ] Dependencies are appropriate and up-to-date
- [ ] Error handling is robust and appropriate
- [ ] Code is readable and maintainable
- [ ] Integration with existing code is seamless

### Review Communication
- Provide constructive and specific feedback
- Explain the reasoning behind review comments
- Suggest specific improvements when requesting changes
- Acknowledge good practices and improvements
- Be respectful and collaborative in discussions

### Follow-up Actions
- Verify that requested changes have been addressed
- Re-review modified code thoroughly
- Test changes locally when appropriate
- Ensure CI/CD pipeline passes before approval
- Document any compromises or technical debt introduced

## Common Review Patterns

### Monorepo Considerations
- Check that package boundaries are respected
- Verify workspace dependencies are appropriate
- Review cross-package integration and compatibility
- Ensure changes don't break dependent packages
- Validate melos configuration and script updates

### State Management Review
- Review BLoC implementation patterns and consistency
- Check state immutability and proper state transitions
- Verify event handling and error propagation
- Review testing patterns for state management
- Ensure proper disposal and cleanup of state objects