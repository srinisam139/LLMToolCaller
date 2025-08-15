import Foundation
import ArgumentParser
import LLMToolCaller

@main
struct LLMToolCallerExample: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "llm-tool-caller-example",
        abstract: "A demonstration of the LLMToolCaller package",
        subcommands: [ListTools.self, CallTool.self, Interactive.self],
        defaultSubcommand: Interactive.self
    )
}

// MARK: - List Tools Command

struct ListTools: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all available tools"
    )
    
    func run() async throws {
        let registry = createRegistry()
        let tools = registry.allToolInfo
        
        print("Available Tools:")
        print("================")
        
        for tool in tools {
            print("• \(tool.name)")
            print("  \(tool.description)")
            print()
        }
        
        print("Total: \(tools.count) tools")
    }
}

// MARK: - Call Tool Command

struct CallTool: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "call",
        abstract: "Execute a specific tool with parameters"
    )
    
    @Argument(help: "The name of the tool to execute")
    var toolName: String
    
    @Option(help: "JSON parameters for the tool")
    var parameters: String = "{}"
    
    @Flag(help: "Pretty print the output")
    var prettyPrint = false
    
    func run() async throws {
        let registry = createRegistry()
        
        // Parse parameters
        guard let paramData = parameters.data(using: .utf8),
              let paramDict = try JSONSerialization.jsonObject(with: paramData) as? [String: Any] else {
            throw ValidationError("Invalid JSON parameters")
        }
        
        let toolCall = LLMToolCall(name: toolName, parameters: paramDict)
        
        print("Executing tool: \(toolName)")
        print("Parameters: \(parameters)")
        print("---")
        
        let result = try await registry.execute(toolCall)
        
        if let error = result.error {
            print("❌ Error: \(error)")
        } else {
            print("✅ Success!")
            
            if prettyPrint {
                let jsonData = try JSONSerialization.data(
                    withJSONObject: result.result,
                    options: [.prettyPrinted, .sortedKeys]
                )
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            } else {
                print("Result: \(result.result)")
            }
        }
    }
}

// MARK: - Interactive Command

struct Interactive: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "interactive",
        abstract: "Interactive mode for exploring tools"
    )
    
    func run() async throws {
        let registry = createRegistry()
        
        print("🔧 LLMToolCaller Interactive Demo")
        print("=================================")
        print()
        print("Available commands:")
        print("  list                 - List all available tools")
        print("  info <tool_name>     - Get information about a tool")
        print("  call <tool_name>     - Execute a tool interactively")
        print("  examples             - Show example tool calls")
        print("  quit                 - Exit the program")
        print()
        
        while true {
            print("Enter command: ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }
            
            if input.isEmpty { continue }
            
            let components = input.components(separatedBy: " ")
            let command = components[0].lowercased()
            
            switch command {
            case "quit", "exit", "q":
                print("Goodbye! 👋")
                return
                
            case "list", "ls":
                await listToolsInteractive(registry: registry)
                
            case "info":
                if components.count > 1 {
                    await showToolInfo(registry: registry, toolName: components[1])
                } else {
                    print("Usage: info <tool_name>")
                }
                
            case "call":
                if components.count > 1 {
                    await callToolInteractive(registry: registry, toolName: components[1])
                } else {
                    print("Usage: call <tool_name>")
                }
                
            case "examples":
                await showExamples()
                
            case "help", "h":
                print("Available commands:")
                print("  list, ls             - List all available tools")
                print("  info <tool_name>     - Get information about a tool")
                print("  call <tool_name>     - Execute a tool interactively")
                print("  examples             - Show example tool calls")
                print("  help, h              - Show this help message")
                print("  quit, exit, q        - Exit the program")
                
            default:
                print("Unknown command: \(command). Type 'help' for available commands.")
            }
            
            print()
        }
    }
    
    func listToolsInteractive(registry: LLMToolRegistry) async {
        let tools = registry.allToolInfo
        print("\nAvailable Tools:")
        print("================")
        for tool in tools {
            print("• \(tool.name) - \(tool.description)")
        }
        print("Total: \(tools.count) tools")
    }
    
    func showToolInfo(registry: LLMToolRegistry, toolName: String) async {
        if let info = registry.toolInfo(for: toolName) {
            print("\nTool: \(info.name)")
            print("Description: \(info.description)")
            
            // Show example usage based on tool type
            switch toolName {
            case "get_weather":
                print("\nExample usage:")
                print("Parameters: {\"location\": \"New York\", \"unit\": \"celsius\"}")
                
            case "calculator":
                print("\nExample usage:")
                print("Parameters: {\"operation\": \"add\", \"operands\": [1, 2, 3]}")
                
            case "text_processor":
                print("\nExample usage:")
                print("Parameters: {\"text\": \"Hello World\", \"operations\": [\"word_count\", \"uppercase\"]}")
                
            default:
                print("\nNo specific example available for this tool.")
            }
        } else {
            print("Tool '\(toolName)' not found.")
        }
    }
    
    func callToolInteractive(registry: LLMToolRegistry, toolName: String) async {
        guard registry.toolInfo(for: toolName) != nil else {
            print("Tool '\(toolName)' not found.")
            return
        }
        
        print("\nEnter parameters as JSON (or press Enter for default):")
        print("Example formats:")
        
        switch toolName {
        case "get_weather":
            print("  {\"location\": \"Paris\", \"unit\": \"celsius\"}")
            print("  {\"location\": \"Tokyo\", \"unit\": \"fahrenheit\", \"include_hourly\": true}")
            
        case "calculator":
            print("  {\"operation\": \"add\", \"operands\": [10, 20, 30]}")
            print("  {\"operation\": \"sqrt\", \"operands\": [16]}")
            
        case "text_processor":
            print("  {\"text\": \"Hello World\", \"operations\": [\"word_count\", \"uppercase\"]}")
            
        default:
            print("  {}")
        }
        
        print("\nParameters: ", terminator: "")
        let parametersInput = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let parameters: [String: Any]
        if parametersInput.isEmpty {
            // Use default parameters
            parameters = getDefaultParameters(for: toolName)
        } else {
            guard let paramData = parametersInput.data(using: .utf8),
                  let paramDict = try? JSONSerialization.jsonObject(with: paramData) as? [String: Any] else {
                print("Invalid JSON parameters")
                return
            }
            parameters = paramDict
        }
        
        let toolCall = LLMToolCall(name: toolName, parameters: parameters)
        
        print("\n⏳ Executing \(toolName)...")
        
        do {
            let result = try await registry.execute(toolCall)
            
            if let error = result.error {
                print("❌ Error: \(error)")
            } else {
                print("✅ Success!")
                await printResult(result.result, for: toolName)
            }
        } catch {
            print("❌ Execution failed: \(error.localizedDescription)")
        }
    }
    
    func getDefaultParameters(for toolName: String) -> [String: Any] {
        switch toolName {
        case "get_weather":
            return ["location": "San Francisco", "unit": "celsius"]
        case "calculator":
            return ["operation": "add", "operands": [10, 20, 30]]
        case "text_processor":
            return ["text": "Hello Swift World!", "operations": ["word_count", "character_count", "uppercase"]]
        default:
            return [:]
        }
    }
    
    func printResult(_ result: Any, for toolName: String) async {
        switch toolName {
        case "get_weather":
            if let weather = result as? WeatherTool.Result {
                print("🌤️  Weather for \(weather.location):")
                print("   Temperature: \(weather.temperature)° \(weather.unit.capitalized)")
                print("   Condition: \(weather.condition)")
                print("   Humidity: \(weather.humidity)%")
                print("   Wind Speed: \(weather.windSpeed) km/h")
                
                if let hourly = weather.hourlyForecast {
                    print("   Hourly forecast available for next 24 hours")
                }
            }
            
        case "calculator":
            if let calc = result as? CalculatorTool.Result {
                print("🧮 Calculation Result:")
                print("   \(calc.expression)")
            }
            
        case "text_processor":
            if let text = result as? TextProcessorTool.Result {
                print("📝 Text Processing Results:")
                print("   Original: \"\(text.originalText)\"")
                for (key, value) in text.results {
                    print("   \(key.replacingOccurrences(of: "_", with: " ").capitalized): \(value)")
                }
            }
            
        default:
            // Generic result printing
            if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Result:")
                print(jsonString)
            } else {
                print("Result: \(result)")
            }
        }
    }
    
    func showExamples() async {
        print("\n📖 Example Tool Calls")
        print("=====================")
        
        print("\n1. Weather Tool:")
        print("   Get weather for a city:")
        print("   call get_weather")
        print("   {\"location\": \"London\", \"unit\": \"celsius\"}")
        
        print("\n2. Calculator Tool:")
        print("   Perform mathematical operations:")
        print("   call calculator")
        print("   {\"operation\": \"multiply\", \"operands\": [7, 8, 9]}")
        
        print("\n3. Text Processor Tool:")
        print("   Analyze and transform text:")
        print("   call text_processor")
        print("   {\"text\": \"Swift is awesome!\", \"operations\": [\"word_count\", \"uppercase\", \"reverse\"]}")
        
        print("\n4. Advanced Examples:")
        print("   Weather with hourly forecast:")
        print("   {\"location\": \"Tokyo\", \"unit\": \"fahrenheit\", \"include_hourly\": true}")
        print()
        print("   Scientific calculator:")
        print("   {\"operation\": \"sin\", \"operands\": [1.5708]}")  // π/2
    }
}

// MARK: - Helper Functions

func createRegistry() -> LLMToolRegistry {
    let registry = LLMToolRegistry()
    
    // Register all available tools
    registry.register(WeatherTool())
    registry.register(CalculatorTool())
    registry.register(TextProcessorTool())
    
    return registry
}