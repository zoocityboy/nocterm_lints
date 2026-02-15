---
applyTo: "**/*.md,**/*.dart"
description: "Documentation standards and requirements for the Rabbit Project"
---

# Documentation Guidelines

## Code Documentation

### Dartdoc Standards
- Document all public classes, methods, and functions
- Use clear and concise language in documentation
- Include usage examples in doc comments
- Document parameters, return values, and exceptions
- Use markdown formatting in dartdoc comments

### API Documentation
- Explain the purpose and behavior of public APIs
- Document expected inputs and outputs
- Include code examples for complex APIs
- Document any side effects or state changes
- Specify thread safety and async behavior

### Code Comments
- Use comments to explain why, not what
- Document complex business logic and algorithms
- Explain non-obvious implementation decisions
- Keep comments up to date with code changes
- Remove obsolete TODO comments promptly

## Package Documentation

### README Files
- Provide clear installation and setup instructions
- Include getting started guide with examples
- Document main features and use cases
- Add badges for build status, coverage, and version
- Include troubleshooting section for common issues

### CHANGELOG Maintenance
- Follow semantic versioning guidelines
- Document all breaking changes clearly
- Include migration guides for major versions
- Date all entries and use consistent formatting
- Group changes by type (features, fixes, breaking)

### Example Code
- Provide runnable examples in example/ directories
- Keep examples simple and focused
- Update examples when APIs change
- Test examples as part of CI pipeline
- Document example requirements and setup

## CLI Documentation

### Help Text
- Write clear and helpful command descriptions
- Provide usage examples for complex commands
- Use consistent terminology across all commands
- Include examples of common use cases
- Document configuration file formats

### User Guides
- Create step-by-step tutorials for common workflows
- Include screenshots or ASCII art for TUI features
- Document keyboard shortcuts and navigation
- Explain configuration options and their effects
- Provide troubleshooting guides

## Architectural Documentation

### Design Decisions
- Document major architectural decisions and rationale
- Explain design patterns used and why
- Document performance considerations
- Include diagrams for complex interactions
- Keep architecture docs up to date

### Package Dependencies
- Document why each dependency is needed
- Explain version constraints and compatibility
- Document any known issues or limitations
- Keep dependency documentation current
- Document alternatives considered

## Documentation Tools

### Generation Tools
- Use dartdoc for generating API documentation
- Integrate documentation generation into CI
- Publish documentation to appropriate platforms
- Keep generated docs synchronized with releases
- Validate links and references automatically

### Documentation Testing
- Test code examples in documentation
- Validate external links regularly
- Check for broken internal references
- Verify documentation builds successfully
- Test installation instructions on clean environments

## Writing Standards

### Style Guidelines
- Use clear, concise, and professional language
- Write in active voice when possible
- Use consistent terminology throughout
- Follow standard markdown formatting
- Use proper grammar and spelling

### Content Organization
- Structure documentation logically
- Use headers and sections appropriately
- Include table of contents for long documents
- Cross-reference related documentation
- Keep related information together

### Accessibility
- Use descriptive link text
- Provide alt text for images and diagrams
- Use sufficient color contrast in visual elements
- Structure content with proper heading hierarchy
- Test documentation with screen readers