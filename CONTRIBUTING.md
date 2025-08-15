# Contributing to LLMToolCaller

Thank you for your interest in contributing to LLMToolCaller! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion for improvement:

1. Check the existing issues to avoid duplicates
2. Create a new issue with:
   - Clear, descriptive title
   - Detailed description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Swift version and platform information

### Pull Requests

1. **Fork the repository** and create a feature branch from `main`
2. **Make your changes** following our coding standards
3. **Add tests** for new functionality
4. **Update documentation** if needed
5. **Ensure all tests pass** by running `swift test`
6. **Submit a pull request** with:
   - Clear description of changes
   - Reference to any related issues
   - Screenshots (if applicable)

## Development Setup

### Prerequisites

- Swift 5.9 or later
- Xcode 15.0+ (for iOS/macOS development)
- Git

### Getting Started

```bash
# Clone your fork
git clone https://github.com/yourusername/LLMToolCaller.git
cd LLMToolCaller

# Build the project
swift build

# Run tests
swift test

# Run the example
swift run LLMToolCallerExample --help
```

## Project Structure

```
LLMToolCaller/
├── Sources/
│   ├── LLMToolCaller/          # Main library code
│   │   ├── LLMTool.swift       # Core protocol and types
│   │   ├── LLMToolRegistry.swift   # Tool management
│   │   └── ExampleTools.swift  # Example implementations
│   └── LLMToolCallerExample/   # CLI example application
├── Tests/
│   └── LLMToolCallerTests/     # Unit tests
├── Package.swift               # Package configuration
└── README.md
```

## Coding Standards

### Swift Style Guide

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful, descriptive names
- Prefer `let` over `var` when possible
- Use trailing closures when appropriate
- Include documentation comments for public APIs

### Code Organization

- Keep files focused on a single responsibility
- Group related functionality together
- Use `// MARK: -` to organize code sections
- Separate public and private interfaces

### Documentation

- All public types and methods should have documentation comments
- Use Swift's documentation comment syntax (`///`)
- Include parameter descriptions and return value information
- Provide usage examples for complex APIs

### Testing

- Write unit tests for all new functionality
- Aim for high test coverage
- Use descriptive test names that explain what is being tested
- Test both success and failure cases
- Mock external dependencies

## Adding New Tools

When contributing new example tools:

1. **Create the tool struct** conforming to `LLMTool`
2. **Define clear parameter and result types**
3. **Implement proper error handling**
4. **Add comprehensive tests**
5. **Update the example CLI** to demonstrate usage
6. **Document the tool's purpose and usage**

Example:

```swift
public struct NewTool: LLMTool {
    public static let name = "new_tool"
    public static let description = "Description of what this tool does"
    
    public struct Parameters: Codable {
        let requiredParam: String
        let optionalParam: Int?
    }
    
    public struct Result: Codable {
        let output: String
        let metadata: [String: String]
    }
    
    public init() {}
    
    public func execute(parameters: Parameters) async throws -> Result {
        // Implementation
    }
}
```

## Performance Considerations

- Prefer `async`/`await` over completion handlers
- Use concurrent execution where appropriate
- Avoid blocking the main thread
- Consider memory usage for large data processing
- Profile performance-critical paths

## Error Handling

- Use `LLMToolError` for tool-specific errors
- Provide meaningful error messages
- Include context in error descriptions
- Handle edge cases gracefully

## Commit Messages

Use clear, descriptive commit messages:

```
feat: add text analysis tool with sentiment detection
fix: handle division by zero in calculator tool
docs: update README with installation instructions
test: add unit tests for concurrent tool execution
```

Prefixes:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Test additions or modifications
- `refactor:` - Code refactoring
- `perf:` - Performance improvements

## Release Process

For maintainers:

1. Update version in `Package.swift`
2. Update `CHANGELOG.md`
3. Create a new release on GitHub
4. Tag the release with semantic versioning

## Getting Help

- Check the [README](README.md) for basic usage
- Look at existing code for patterns and examples
- Ask questions in GitHub issues
- Review the test suite for usage examples

## Recognition

Contributors will be acknowledged in:
- GitHub contributors list
- Release notes for significant contributions
- README acknowledgments section

Thank you for helping make LLMToolCaller better! 🚀