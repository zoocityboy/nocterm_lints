---
mode: 'agent'
model: GPT-5 mini (copilot)
tools: ['codebase', 'fileRead', 'search']
description: 'Provide comprehensive code review assistance'
---

# Code Review Prompt

Your goal is to provide thorough and constructive code review for the Rabbit Project, following the established [code review guidelines](../instructions/code-review.instructions.md).

## Review Focus Areas

### Code Quality Review
- Verify adherence to Dart conventions and project coding standards
- Check for proper error handling and resource management
- Review algorithmic efficiency and performance considerations
- Assess code readability, maintainability, and documentation quality
- Validate public API design and consistency

### Architecture and Design
- Review compliance with established architectural patterns
- Check proper separation of concerns and modularity
- Verify integration with existing codebase components
- Assess design decisions and their alignment with project goals
- Review abstraction levels and interface design

### Security Assessment
- Review input validation and sanitization
- Check for potential security vulnerabilities
- Verify proper handling of sensitive data and credentials
- Assess network security and API usage patterns
- Review access controls and permission handling

### Performance Analysis
- Identify potential performance bottlenecks or regressions
- Review memory usage and resource management patterns
- Assess algorithm and data structure efficiency
- Check I/O operations and network request efficiency
- Evaluate scalability implications of proposed changes

### Testing Evaluation
- Review test coverage and test quality
- Check that tests are meaningful and test actual behavior
- Verify edge cases and error conditions are tested
- Assess test structure, organization, and maintainability
- Review async test handling and mock usage

## Review Process

### Initial Assessment
1. **Understand Context**
   - Review the purpose and scope of the changes
   - Understand the problem being solved
   - Check related issues, requirements, or documentation

2. **Analyze Structure**
   - Review file organization and naming conventions
   - Check package boundaries and dependencies
   - Assess integration points with existing code

3. **Examine Implementation**
   - Review algorithm choices and logic flow
   - Check error handling and edge case coverage
   - Verify resource management and cleanup
   - Assess thread safety and concurrency handling

### Detailed Review

#### Dart-Specific Checks
- Verify proper use of null safety features
- Check for appropriate use of const and final
- Review async/await usage and error propagation
- Verify proper disposal of streams and controllers
- Check dartdoc quality and completeness

#### BLoC Pattern Review
- Verify proper state and event design
- Check state immutability and transitions
- Review error handling in state management
- Assess BLoC disposal and resource cleanup
- Verify testing patterns for state management

#### CLI Application Review
- Review command structure and argument parsing
- Check user experience and error messaging
- Verify terminal compatibility and output formatting
- Assess help text and documentation quality
- Review interactive features and responsiveness

#### Package Development Review
- Check public API design and documentation
- Review semantic versioning and compatibility
- Verify example code functionality
- Assess dependency management and constraints
- Review package metadata and configuration

## Review Feedback Guidelines

### Constructive Feedback
- Provide specific, actionable suggestions
- Explain the reasoning behind recommendations
- Include code examples for suggested improvements
- Acknowledge good practices and improvements
- Prioritize feedback by severity and importance

### Communication Style
- Be respectful and collaborative
- Focus on the code, not the developer
- Ask questions when unclear about intent
- Suggest alternatives rather than just pointing out problems
- Recognize learning opportunities and knowledge sharing

### Review Comments Categories

#### 🔴 Critical Issues
- Security vulnerabilities or risks
- Performance problems or memory leaks
- Breaking changes without proper migration
- Incorrect algorithm implementation
- Missing error handling for critical paths

#### 🟡 Suggestions
- Code style and convention improvements
- Performance optimizations
- Better variable or function naming
- Documentation improvements
- Test coverage enhancements

#### 💡 Learning Opportunities
- Alternative approaches or patterns
- Best practices and conventions
- Performance tips and optimizations
- Security considerations
- Testing strategies

#### ✅ Positive Feedback
- Well-designed APIs or implementations
- Good test coverage and structure
- Clear documentation and comments
- Proper error handling
- Performance improvements

## Review Completion

### Final Checks
- Verify all critical issues have been addressed
- Ensure tests pass and coverage is adequate
- Check that documentation is complete and accurate
- Confirm integration with existing systems works
- Validate that CI/CD pipeline passes successfully

### Approval Criteria
- Code meets quality standards and follows conventions
- Tests are comprehensive and maintainable
- Documentation is complete and accurate
- Security considerations have been addressed
- Performance impact has been evaluated
- Integration with existing code is seamless

Provide detailed, constructive feedback focused on code quality, security, performance, and maintainability while following the project's established standards and patterns.