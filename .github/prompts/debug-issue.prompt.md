---
mode: 'agent'
model: GPT-5 mini (copilot)
tools: ['codebase', 'fileRead', 'search', 'usages']
description: 'Debug issues, analyze problems, and provide solutions'
---

# Debug Issue Prompt

Your goal is to systematically analyze and debug issues in the Rabbit Project, providing comprehensive solutions and preventive measures.

## Debugging Approach

### 1. Issue Understanding
- **Reproduce the Problem**: Understand the exact steps that lead to the issue
- **Gather Information**: Collect error messages, logs, stack traces, and environment details
- **Identify Symptoms**: Distinguish between root causes and symptoms
- **Assess Impact**: Understand the scope and severity of the issue

### 2. Systematic Analysis
- **Review Recent Changes**: Check recent commits, deployments, or configuration changes
- **Analyze Error Patterns**: Look for patterns in error messages, timing, or conditions
- **Check Dependencies**: Verify external service status, library versions, and compatibility
- **Environment Factors**: Consider differences between development, staging, and production

### 3. Root Cause Investigation
- **Code Analysis**: Review relevant code sections for logic errors or edge cases
- **Data Flow Tracing**: Follow data through the system to identify transformation issues
- **Resource Analysis**: Check memory usage, file handles, network connections, and other resources
- **Concurrency Issues**: Look for race conditions, deadlocks, or synchronization problems

## Common Issue Categories

### CLI Application Issues
- **Startup Problems**: Dependency loading, configuration errors, environment setup
- **Command Failures**: Argument parsing, validation errors, execution failures
- **Output Issues**: Formatting problems, encoding issues, terminal compatibility
- **Performance Problems**: Slow startup, memory usage, resource consumption
- **User Experience**: Confusing error messages, missing help text, poor usability

### State Management Issues
- **BLoC Problems**: Incorrect state transitions, memory leaks, error propagation
- **Data Synchronization**: State inconsistency, stale data, update conflicts
- **Event Handling**: Missing events, duplicate processing, async timing issues
- **Resource Management**: Unclosed streams, undisposed controllers, memory leaks

### Network and API Issues
- **Connection Problems**: Network timeouts, SSL certificate issues, firewall blocks
- **Authentication Failures**: Token expiration, credential issues, permission problems
- **Data Issues**: Malformed responses, encoding problems, version mismatches
- **Rate Limiting**: API quota exceeded, throttling issues, retry logic problems

### Package and Dependency Issues
- **Version Conflicts**: Incompatible package versions, dependency resolution problems
- **Missing Dependencies**: Unresolved imports, missing dev dependencies
- **Build Issues**: Code generation failures, compilation errors, configuration problems
- **Integration Issues**: Package boundary violations, circular dependencies

### Performance and Resource Issues
- **Memory Problems**: Memory leaks, excessive allocation, garbage collection issues
- **CPU Issues**: Infinite loops, inefficient algorithms, blocking operations
- **I/O Problems**: File access errors, disk space issues, slow operations
- **Scaling Issues**: Performance degradation under load, resource exhaustion

## Debugging Techniques

### Logging and Instrumentation
- **Add Diagnostic Logging**: Insert strategic log statements to trace execution flow
- **Use Structured Logging**: Include relevant context and identifiers in log messages
- **Enable Debug Mode**: Use development flags and debug builds for additional information
- **Monitor Resource Usage**: Track memory, CPU, and I/O usage during problem scenarios

### Code Analysis Tools
- **Static Analysis**: Use dart analyzer and linting tools to identify potential issues
- **Code Review**: Manually review code for logic errors and edge cases
- **Dependency Analysis**: Check package dependencies and version compatibility
- **Security Scanning**: Look for security vulnerabilities and unsafe practices

### Testing and Reproduction
- **Write Reproducible Tests**: Create tests that consistently demonstrate the problem
- **Isolate Components**: Test individual components in isolation to narrow down issues
- **Environment Testing**: Test in different environments and configurations
- **Load Testing**: Reproduce issues under various load and stress conditions

### Profiling and Monitoring
- **Performance Profiling**: Use Dart DevTools to analyze CPU and memory usage
- **Network Monitoring**: Capture and analyze network traffic and API calls
- **System Monitoring**: Monitor system resources and external service status
- **User Behavior Analysis**: Understand how users encounter and experience issues

## Solution Development

### Immediate Fixes
- **Hotfixes**: Provide immediate workarounds for critical production issues
- **Error Handling**: Add proper error handling and graceful degradation
- **Input Validation**: Strengthen validation to prevent invalid operations
- **Resource Cleanup**: Ensure proper cleanup of resources and connections

### Comprehensive Solutions
- **Root Cause Fix**: Address the underlying cause rather than just symptoms
- **Robustness Improvements**: Make code more resilient to edge cases and failures
- **Performance Optimization**: Optimize algorithms and resource usage
- **User Experience**: Improve error messages and user feedback

### Preventive Measures
- **Additional Testing**: Add tests to prevent regression of the fixed issue
- **Monitoring**: Implement monitoring and alerting for similar issues
- **Documentation**: Document known issues and their solutions
- **Code Review**: Improve review processes to catch similar issues early

## Dart-Specific Debugging

### Null Safety Issues
- **Null Check Failures**: Analyze nullable types and null assertions
- **Late Initialization**: Debug late variable access and initialization timing
- **Optional Chaining**: Review null-aware operators and their usage
- **Type Promotion**: Understand type promotion and null check patterns

### Async/Await Problems
- **Future Chains**: Debug future composition and error propagation
- **Stream Issues**: Analyze stream subscriptions, cancellation, and disposal
- **Error Handling**: Review async error handling and try-catch placement
- **Deadlocks**: Identify potential deadlocks in async operations

### Memory Management
- **Stream Subscriptions**: Check for unclosed streams and subscriptions
- **Event Listeners**: Verify proper removal of event listeners and callbacks
- **Circular References**: Identify and break circular reference patterns
- **Resource Disposal**: Ensure proper disposal of controllers and resources

### Package Issues
- **Dependency Conflicts**: Resolve version conflicts and dependency issues
- **Import Errors**: Debug import statements and package resolution
- **Build Problems**: Analyze build failures and code generation issues
- **Platform Compatibility**: Check platform-specific compatibility and features

## Documentation and Communication

### Issue Documentation
- **Reproduction Steps**: Document exact steps to reproduce the issue
- **Environment Details**: Include version numbers, platform information, and configuration
- **Solution Description**: Clearly explain the fix and why it works
- **Testing Instructions**: Provide steps to verify the fix works correctly

### Knowledge Sharing
- **Post-Mortem Analysis**: Conduct thorough analysis of significant issues
- **Best Practices**: Update coding standards to prevent similar issues
- **Team Communication**: Share learnings and solutions with the development team
- **User Communication**: Inform users of fixes and workarounds when appropriate

Provide systematic analysis of the issue, clear explanation of the root cause, comprehensive solution with implementation steps, and preventive measures to avoid similar problems in the future.