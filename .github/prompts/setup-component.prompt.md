---
mode: 'agent'
model: Grok Code Fast 1 (copilot)
tools: ['codebase', 'fileCreate', 'fileEdit']
description: 'Generate a new Dart package or CLI command component'
---

# Setup Component Prompt

Your goal is to create a new component for the Rabbit Project based on the provided requirements.

## Component Types

Ask which type of component to create if not specified:

1. **New Package** - Reusable library in packages/
2. **CLI Command** - New command in apps/rabbit/src/commands/
3. **BLoC/Cubit** - State management component
4. **Repository** - Data access layer component
5. **Service** - Business logic service

## Requirements for Each Type

### New Package
- Use proper package structure with lib/, test/, example/
- Include comprehensive pubspec.yaml with correct dependencies
- Create README.md with usage examples
- Add CHANGELOG.md with initial version
- Include analysis_options.yaml for consistent linting
- Set up proper export files in lib/

### CLI Command
- Extend the base command pattern used in the project
- Include proper argument parsing and validation
- Provide helpful usage information and examples
- Implement proper error handling and user feedback
- Add comprehensive tests for command functionality
- Update main command registry

### BLoC/Cubit Components
- Follow the established BLoC patterns in the project
- Use proper state and event class hierarchies
- Include comprehensive unit tests using bloc_test
- Implement proper error handling and loading states
- Document state transitions and business logic
- Use dependency injection patterns with get_it

### Repository Components
- Follow the repository pattern used in the project
- Define clear interfaces and implementation contracts
- Include proper error handling and data transformation
- Implement caching strategies where appropriate
- Add comprehensive tests with proper mocking
- Document data sources and transformation logic

### Service Components
- Design focused single-responsibility services
- Use proper dependency injection and interfaces
- Include comprehensive error handling and logging
- Implement proper resource cleanup and lifecycle management
- Add thorough unit tests with appropriate mocking
- Document service contracts and usage patterns

## Implementation Steps

1. **Analyze Requirements**
   - Understand the component's purpose and scope
   - Identify dependencies and integration points
   - Plan the public API and interface design

2. **Create Structure**
   - Set up appropriate directory structure
   - Create necessary configuration files
   - Set up basic class structure and interfaces

3. **Implement Core Logic**
   - Implement the main functionality
   - Add proper error handling and validation
   - Include logging and monitoring where appropriate

4. **Add Tests**
   - Create comprehensive unit tests
   - Add integration tests where appropriate
   - Verify error handling and edge cases

5. **Document Component**
   - Add dartdoc comments to public APIs
   - Create or update README documentation
   - Include usage examples and integration guides

6. **Integration**
   - Update dependency configurations
   - Register components with dependency injection
   - Update main application or package exports

## Code Quality Requirements

- Follow all Dart language conventions and project standards
- Use meaningful names and clear interfaces
- Include proper error handling and resource management
- Write comprehensive tests with good coverage
- Document public APIs and complex logic
- Ensure components integrate cleanly with existing code

Ask for specific requirements if the component type and purpose are not clear from the request.