---
applyTo: "**/*.dart"
description: "Security best practices and requirements for the Rabbit Project"
---

# Security Guidelines

## Input Validation and Sanitization

### CLI Input Security
- Validate all command-line arguments and options
- Sanitize file paths to prevent directory traversal attacks
- Limit input lengths to prevent buffer overflow-like issues
- Validate data types and ranges for numeric inputs
- Reject unexpected or malformed inputs gracefully

### Data Validation
- Use strong typing to prevent type-related vulnerabilities
- Validate data at API boundaries
- Sanitize user-provided data before processing
- Use allowlists rather than blocklists when possible
- Implement proper error handling for invalid inputs

## Network Security

### API Communications
- Use HTTPS for all external API communications
- Validate SSL certificates properly
- Implement proper timeout handling
- Use secure authentication methods
- Handle network errors securely without leaking information

### WebSocket Security
- Validate all incoming WebSocket messages
- Implement proper authentication for WebSocket connections
- Use secure WebSocket protocols (wss://)
- Implement rate limiting for WebSocket messages
- Handle connection failures securely

## Credential and Secret Management

### API Keys and Tokens
- Never hardcode API keys or secrets in source code
- Use environment variables for configuration secrets
- Implement secure storage for persistent credentials
- Rotate credentials regularly when possible
- Use minimal privilege principles for API access

### Configuration Security
- Secure configuration files with appropriate permissions
- Validate configuration values thoroughly
- Use secure defaults for all configuration options
- Document security implications of configuration changes
- Encrypt sensitive configuration data when stored

## File System Security

### File Operations
- Validate file paths to prevent unauthorized access
- Use appropriate file permissions for created files
- Clean up temporary files securely
- Avoid following symbolic links to unauthorized locations
- Implement proper error handling for file operations

### Data Storage
- Encrypt sensitive data at rest when appropriate
- Use secure file formats and avoid storing raw credentials
- Implement proper data retention and deletion policies
- Secure backup and restore operations
- Validate file integrity when reading critical data

## Error Handling and Information Disclosure

### Secure Error Handling
- Avoid exposing sensitive information in error messages
- Log security events appropriately
- Use structured logging for security-relevant events
- Implement consistent error handling across the application
- Provide helpful but not revealing error messages to users

### Logging Security
- Never log sensitive data like passwords or API keys
- Use appropriate log levels for different types of events
- Secure log files with proper permissions
- Implement log rotation and retention policies
- Monitor logs for security events

## Dependency Security

### Package Management
- Regularly update dependencies to get security fixes
- Use dependency scanning tools to identify vulnerabilities
- Review new dependencies for security implications
- Monitor security advisories for used packages
- Remove unused dependencies promptly

### Third-Party Code
- Review third-party code for security issues
- Use well-maintained and reputable packages
- Implement proper isolation for third-party code
- Monitor for security updates and patches
- Have fallback plans for compromised dependencies

## Runtime Security

### Memory Management
- Avoid storing sensitive data longer than necessary
- Clear sensitive data from memory when possible
- Use appropriate data structures for sensitive information
- Implement secure random number generation
- Handle memory allocation failures securely

### Process Security
- Run with minimal necessary privileges
- Implement proper signal handling
- Secure inter-process communication when used
- Monitor resource usage to prevent abuse
- Implement timeout mechanisms for long-running operations

## Compliance and Standards

### Security Standards
- Follow OWASP guidelines for relevant vulnerabilities
- Implement security by design principles
- Use established cryptographic algorithms and libraries
- Follow platform-specific security recommendations
- Document security assumptions and requirements

### Privacy Protection
- Handle personal data according to privacy requirements
- Implement data minimization principles
- Provide clear privacy policies for data collection
- Implement user consent mechanisms where required
- Secure data transmission and storage appropriately