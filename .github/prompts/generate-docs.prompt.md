---
mode: 'agent'
model: GPT-5 mini (copilot)
tools: ['codebase', 'fileCreate', 'fileEdit', 'search']
description: 'Generate comprehensive documentation for code, APIs, and project features'
---

# Generate Documentation Prompt

Your goal is to create comprehensive, accurate, and helpful documentation for the Rabbit Project following the established [documentation standards](../instructions/documentation.instructions.md).

## Documentation Types

### API Documentation
- Generate dartdoc comments for public classes, methods, and functions
- Include clear descriptions of parameters, return values, and exceptions
- Provide usage examples and code snippets
- Document behavior, side effects, and threading considerations
- Include links to related APIs and resources

### Package Documentation
- Create or update README.md files with installation and setup instructions
- Generate getting started guides with practical examples
- Document main features, use cases, and limitations
- Create troubleshooting sections for common issues
- Include API reference and migration guides

### CLI Documentation
- Generate help text and usage information for commands
- Create user guides with step-by-step tutorials
- Document configuration options and environment variables
- Provide examples of common workflows and use cases
- Include troubleshooting and error resolution guides

### Architectural Documentation
- Document design decisions and architectural patterns
- Create system overview and component interaction diagrams
- Explain data flow and state management patterns
- Document integration points and external dependencies
- Include performance considerations and scalability notes

## Documentation Generation Process

### 1. Code Analysis
- **Analyze Structure**: Review the codebase to understand components and their relationships
- **Identify APIs**: Find public interfaces, classes, and functions that need documentation
- **Review Usage**: Understand how components are used and their typical usage patterns
- **Check Existing Docs**: Review current documentation for gaps and outdated information

### 2. Content Creation
- **Write Clear Descriptions**: Create concise but comprehensive descriptions of functionality
- **Include Examples**: Add practical code examples and usage scenarios
- **Document Edge Cases**: Explain behavior in edge cases and error conditions
- **Cross-Reference**: Link related APIs, features, and documentation sections

### 3. Validation and Testing
- **Test Examples**: Verify that all code examples compile and run correctly
- **Check Links**: Validate all internal and external links work properly
- **Review Accuracy**: Ensure documentation matches current implementation
- **Test Instructions**: Follow setup and usage instructions to verify accuracy

## Dart-Specific Documentation

### Dartdoc Comments
- Use triple-slash (`///`) comments for documentation
- Include parameter descriptions with `[paramName]` references
- Document return values and possible exceptions
- Use markdown formatting for better readability
- Include `@deprecated` annotations for deprecated APIs

### Code Examples
- Provide complete, runnable code examples
- Show both basic usage and advanced scenarios
- Include error handling and best practices
- Demonstrate integration with other project components
- Use realistic data and scenarios in examples

### Package Documentation Structure
```
README.md              # Main package overview and getting started
CHANGELOG.md          # Version history and changes
example/              # Runnable example applications
doc/                  # Additional documentation files
API.md               # Detailed API reference
CONTRIBUTING.md      # Development and contribution guidelines
```

## Content Guidelines

### Writing Style
- Use clear, concise, and professional language
- Write in active voice when possible
- Use consistent terminology throughout documentation
- Explain complex concepts in simple terms
- Provide context and background for complex features

### Structure and Organization
- Use logical hierarchy with clear headings and sections
- Include table of contents for longer documents
- Cross-reference related information appropriately
- Group related information together
- Use consistent formatting and styling

### Code Examples and Snippets
- Provide complete, working examples whenever possible
- Include necessary imports and setup code
- Show both success and error handling scenarios
- Use meaningful variable names and realistic data
- Keep examples focused and avoid unnecessary complexity

### Visual Elements
- Use diagrams for architectural overviews when helpful
- Include screenshots for CLI tools and user interfaces
- Use tables for comparing options or listing parameters
- Apply consistent formatting for code blocks and commands
- Use appropriate markdown syntax for emphasis and structure

## Specific Documentation Types

### CLI Command Documentation
- Document all command-line options and arguments
- Provide examples of common usage patterns
- Explain configuration file formats and options
- Include troubleshooting for common user issues
- Document environment variable usage and defaults

### BLoC/State Management Documentation
- Explain state hierarchies and transitions
- Document event types and their effects
- Provide examples of proper usage patterns
- Explain error handling and recovery strategies
- Document testing approaches and best practices

### Repository and Service Documentation
- Document data models and transformation logic
- Explain caching strategies and invalidation policies
- Document error handling and retry mechanisms
- Provide configuration and dependency information
- Include performance considerations and limitations

### Integration Documentation
- Explain how components work together
- Document data flow between layers
- Provide setup and configuration instructions
- Include troubleshooting for integration issues
- Document version compatibility and migration paths

## Quality Assurance

### Documentation Testing
- Test all code examples for accuracy and completeness
- Verify setup instructions work on clean environments
- Check that links and references are correct and current
- Validate that documentation matches implementation
- Test CLI commands and configuration examples

### Review and Maintenance
- Review documentation for clarity and completeness
- Update documentation when code changes
- Remove outdated information and examples
- Keep external links current and functional
- Maintain consistent style and formatting

### Accessibility and Usability
- Use descriptive link text and headings
- Provide alternative text for images and diagrams
- Structure content with proper heading hierarchy
- Ensure sufficient contrast in visual elements
- Test documentation with screen readers when applicable

## Documentation Tools and Integration

### Generation Tools
- Use dartdoc for generating API documentation
- Integrate documentation builds into CI/CD pipeline
- Set up automated link checking and validation
- Use consistent formatting and styling tools
- Publish documentation to appropriate platforms

### Version Management
- Keep documentation versioned with code releases
- Maintain documentation for multiple versions when needed
- Document breaking changes and migration paths
- Archive outdated documentation appropriately
- Ensure documentation deployment matches code deployment

Provide comprehensive, accurate documentation that helps users understand and effectively use the project components. Focus on clarity, completeness, and practical value for developers and users.