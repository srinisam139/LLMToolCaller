# LLMToolCaller

A Swift package for wrapping LLM tool-calling with structured outputs, providing type-safe function definitions and execution capabilities.

## Features

- 🔧 Type-safe tool definition and execution
- 📝 Structured input/output validation
- 🚀 Easy integration with any LLM API
- 🧪 Comprehensive unit test coverage
- 📚 Well-documented API with examples

## Requirements

- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/LLMToolCaller.git", from: "1.0.0")
]
```

Or add it through Xcode by going to File → Add Package Dependencies and entering the repository URL.

## Quick Start

```swift
import LLMToolCaller

// Define a tool
struct WeatherTool: LLMTool {
    static let name = "get_weather"
    static let description = "Get weather information for a location"
    
    struct Parameters: Codable {
        let location: String
        let unit: String?
    }
    
    struct Result: Codable {
        let temperature: Double
        let condition: String
        let location: String
    }
    
    func execute(parameters: Parameters) async throws -> Result {
        // Your weather API implementation
        return Result(
            temperature: 72.0,
            condition: "Sunny",
            location: parameters.location
        )
    }
}

// Register and use tools
let toolRegistry = LLMToolRegistry()
toolRegistry.register(WeatherTool())

// Execute a tool call
let toolCall = LLMToolCall(
    name: "get_weather",
    parameters: ["location": "New York", "unit": "fahrenheit"]
)

let result = try await toolRegistry.execute(toolCall)
print(result)
```

## Core Components

### LLMTool Protocol

Define your tools by conforming to the `LLMTool` protocol:

```swift
protocol LLMTool {
    static var name: String { get }
    static var description: String { get }
    associatedtype Parameters: Codable
    associatedtype Result: Codable
    
    func execute(parameters: Parameters) async throws -> Result
}
```

### LLMToolRegistry

Manage and execute your tools:

```swift
let registry = LLMToolRegistry()
registry.register(WeatherTool())
registry.register(CalculatorTool())

// Get available tools
let availableTools = registry.availableTools

// Execute a tool
let result = try await registry.execute(toolCall)
```

### Structured Outputs

All tool inputs and outputs are strongly typed and validated:

```swift
struct CalculatorParameters: Codable {
    let operation: Operation
    let operands: [Double]
    
    enum Operation: String, Codable {
        case add, subtract, multiply, divide
    }
}
```

## Examples

Check out the `Sources/LLMToolCallerExample` directory for a complete CLI example that demonstrates:

- Tool registration
- Parameter validation
- Error handling
- Real-world usage patterns

Run the example:

```bash
swift run LLMToolCallerExample --help
```

## Testing

Run the test suite:

```bash
swift test
```

The package includes comprehensive unit tests covering:

- Tool registration and execution
- Parameter validation
- Error handling
- Edge cases

## Documentation

Generate documentation using Swift-DocC:

```bash
swift package generate-documentation
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Swift's modern concurrency features
- Inspired by OpenAI's function calling capabilities
- Designed for type safety and developer experience