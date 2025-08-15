# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial implementation of LLMToolCaller package
- Core `LLMTool` protocol for defining structured tools
- `LLMToolRegistry` for managing and executing tools
- Comprehensive error handling with `LLMToolError`
- Type-safe parameter validation and result handling
- Concurrent tool execution support
- Example tool implementations:
  - `WeatherTool` - Mock weather information retrieval
  - `CalculatorTool` - Mathematical operations
  - `TextProcessorTool` - Text analysis and transformation
- Interactive CLI example application
- Comprehensive unit test suite
- Full documentation and API examples
- GitHub Actions CI/CD pipeline
- Swift Package Manager support
- Multi-platform compatibility (iOS, macOS, tvOS, watchOS)

### Features
- **Type Safety**: All tool inputs and outputs are strongly typed and validated
- **Async/Await**: Native Swift concurrency support
- **Error Handling**: Comprehensive error types and handling
- **Extensibility**: Easy to add new tools through protocol conformance
- **Testing**: Full unit test coverage with examples
- **Documentation**: Complete API documentation with usage examples
- **CLI Tool**: Interactive example demonstrating all features

### Technical Details
- Minimum Swift version: 5.9
- Supported platforms: iOS 16.0+, macOS 13.0+, tvOS 16.0+, watchOS 9.0+
- Dependencies: Swift Argument Parser (for CLI example only)
- Architecture: Protocol-oriented design with type erasure for flexibility

### Examples
- Weather information retrieval with optional hourly forecasts
- Mathematical calculations including basic arithmetic and scientific functions
- Text processing with word counting, transformations, and analysis
- Interactive CLI for exploring tool capabilities
- Concurrent execution of multiple tools

## [1.0.0] - TBD

### Added
- Initial public release
- Core functionality as described above
- Full documentation and examples
- CI/CD pipeline setup
- Package ready for distribution

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.