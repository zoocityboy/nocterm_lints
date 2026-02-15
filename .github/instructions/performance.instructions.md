---
applyTo: "**/*.dart"
description: "Performance optimization guidelines for the Rabbit Project"
---

# Performance Guidelines

## General Performance Principles

### Measurement First
- Profile before optimizing to identify real bottlenecks
- Use Dart's built-in DevTools for performance analysis
- Set up benchmarks for performance-critical code paths
- Monitor memory usage and garbage collection patterns
- Establish performance baselines and regression testing

### Algorithmic Efficiency
- Choose appropriate data structures for specific use cases
- Prefer O(1) and O(log n) operations over O(n) when possible
- Use efficient algorithms for sorting, searching, and data processing
- Avoid nested loops when alternatives exist
- Cache expensive computations when appropriate

## Memory Optimization

### Object Creation
- Use const constructors for immutable objects
- Prefer object reuse over frequent allocation and disposal
- Use object pools for frequently created and destroyed objects
- Avoid creating unnecessary intermediate objects
- Use appropriate collection types based on access patterns

### Memory Management
- Dispose of controllers, streams, and resources promptly
- Close files, network connections, and other system resources
- Use weak references to avoid memory leaks in callback patterns
- Monitor memory usage in long-running CLI applications
- Implement proper cleanup in error handling paths

## Asymptotic Performance

### Collection Operations
- Use appropriate collection types (List, Set, Map) based on access patterns
- Prefer LinkedHashMap over HashMap when insertion order matters
- Use efficient iteration patterns (for-in loops, forEach, map)
- Avoid unnecessary collection conversions
- Use lazy evaluation with Iterable operations when appropriate

### String Processing
- Use StringBuffer for building strings iteratively
- Prefer string interpolation over concatenation
- Cache compiled regular expressions when used repeatedly
- Use efficient string comparison methods
- Minimize string allocations in hot code paths

## I/O and Network Performance

### File Operations
- Use streaming operations for large files
- Implement proper buffering for file I/O
- Use asynchronous file operations to avoid blocking
- Cache file metadata when accessed frequently
- Implement efficient file watching and monitoring

### Network Operations
- Use connection pooling for HTTP requests
- Implement appropriate timeouts and retry logic
- Use streaming for large data transfers
- Cache network responses when appropriate
- Implement efficient error handling for network failures

### Concurrent Operations
- Use isolates for CPU-intensive tasks
- Design for parallelism when processing independent data
- Use appropriate synchronization primitives
- Avoid excessive context switching
- Balance concurrency with resource constraints

## CLI Application Performance

### Startup Performance
- Minimize initialization time for CLI commands
- Use lazy loading for non-essential components
- Optimize import dependencies and startup code paths
- Cache configuration and frequently accessed data
- Implement efficient command parsing and routing

### Interactive Performance
- Respond to user input within acceptable latency
- Use efficient screen updating for TUI applications
- Implement proper debouncing for rapid user interactions
- Optimize rendering loops and screen drawing
- Provide responsive feedback for long-running operations

### Resource Usage
- Monitor CPU and memory usage in production
- Implement resource limits and usage monitoring
- Use efficient data structures for large datasets
- Implement proper cleanup and resource management
- Design for scalability with varying input sizes

## BLoC Performance

### State Management
- Use efficient state comparison and equality checking
- Avoid unnecessary state emissions and rebuilds
- Implement proper state caching when beneficial
- Use appropriate granularity for state updates
- Design state classes for efficient serialization when needed

### Event Processing
- Use efficient event queuing and processing
- Avoid blocking operations in event handlers
- Implement proper error handling without performance impact
- Use debouncing and throttling for high-frequency events
- Design events for minimal processing overhead

## Development Performance

### Build Performance
- Optimize dependency resolution and package structure
- Use efficient code generation when required
- Minimize build artifacts and intermediate files
- Implement incremental builds where possible
- Monitor and optimize CI/CD pipeline performance

### Testing Performance
- Write efficient unit tests with minimal setup overhead
- Use appropriate test fixtures and data generation
- Implement parallel test execution where beneficial
- Optimize integration test setup and teardown
- Balance test coverage with execution time

## Monitoring and Maintenance

### Performance Monitoring
- Implement application performance monitoring
- Set up alerts for performance regressions
- Monitor key performance indicators regularly
- Use profiling tools to identify optimization opportunities
- Track performance trends over time

### Performance Testing
- Include performance tests in the CI pipeline
- Test with realistic data sizes and usage patterns
- Verify performance across different environments
- Test memory usage and resource consumption
- Establish performance benchmarks and SLAs