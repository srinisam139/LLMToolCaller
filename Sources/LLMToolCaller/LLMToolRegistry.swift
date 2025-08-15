import Foundation

/// A registry for managing and executing LLM tools
public class LLMToolRegistry {
    private var tools: [String: any LLMToolExecutor] = [:]
    
    public init() {}
    
    /// Register a tool in the registry
    /// - Parameter tool: The tool to register
    public func register<T: LLMTool>(_ tool: T) {
        let executor = AnyLLMToolExecutor(tool: tool)
        tools[T.name] = executor
    }
    
    /// Get all available tool names
    public var availableTools: [String] {
        return Array(tools.keys).sorted()
    }
    
    /// Get tool information for a specific tool
    /// - Parameter name: The name of the tool
    /// - Returns: Tool information including name and description
    public func toolInfo(for name: String) -> LLMToolInfo? {
        guard let executor = tools[name] else { return nil }
        return LLMToolInfo(name: executor.name, description: executor.description)
    }
    
    /// Get all tool information
    public var allToolInfo: [LLMToolInfo] {
        return tools.values.map { executor in
            LLMToolInfo(name: executor.name, description: executor.description)
        }.sorted { $0.name < $1.name }
    }
    
    /// Execute a tool call
    /// - Parameter toolCall: The tool call to execute
    /// - Returns: The result of the tool execution
    /// - Throws: LLMToolError if the tool is not found or execution fails
    public func execute(_ toolCall: LLMToolCall) async throws -> LLMToolResult {
        guard let executor = tools[toolCall.name] else {
            let error = LLMToolError.toolNotFound(toolCall.name)
            return LLMToolResult(toolCall: toolCall, result: [:], error: error.localizedDescription)
        }
        
        do {
            let result = try await executor.execute(parameters: toolCall.parameters)
            return LLMToolResult(toolCall: toolCall, result: result)
        } catch {
            return LLMToolResult(toolCall: toolCall, result: [:], error: error.localizedDescription)
        }
    }
    
    /// Execute multiple tool calls concurrently
    /// - Parameter toolCalls: The tool calls to execute
    /// - Returns: An array of tool results in the same order as the input
    public func executeAll(_ toolCalls: [LLMToolCall]) async -> [LLMToolResult] {
        return await withTaskGroup(of: (Int, LLMToolResult).self, returning: [LLMToolResult].self) { group in
            for (index, toolCall) in toolCalls.enumerated() {
                group.addTask {
                    do {
                        let result = try await self.execute(toolCall)
                        return (index, result)
                    } catch {
                        let errorResult = LLMToolResult(toolCall: toolCall, result: [:], error: error.localizedDescription)
                        return (index, errorResult)
                    }
                }
            }
            
            var results: [(Int, LLMToolResult)] = []
            for await result in group {
                results.append(result)
            }
            
            // Sort by original index to maintain order
            results.sort { $0.0 < $1.0 }
            return results.map { $0.1 }
        }
    }
    
    /// Remove a tool from the registry
    /// - Parameter name: The name of the tool to remove
    /// - Returns: True if the tool was removed, false if it wasn't found
    @discardableResult
    public func unregister(_ name: String) -> Bool {
        return tools.removeValue(forKey: name) != nil
    }
    
    /// Clear all registered tools
    public func clear() {
        tools.removeAll()
    }
}

/// Information about a registered tool
public struct LLMToolInfo: Codable {
    public let name: String
    public let description: String
    
    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}

/// Internal protocol for type-erased tool execution
protocol LLMToolExecutor {
    var name: String { get }
    var description: String { get }
    func execute(parameters: [String: Any]) async throws -> Any
}

/// Type-erased wrapper for LLMTool instances
struct AnyLLMToolExecutor<T: LLMTool>: LLMToolExecutor {
    private let tool: T
    
    var name: String { T.name }
    var description: String { T.description }
    
    init(tool: T) {
        self.tool = tool
    }
    
    func execute(parameters: [String: Any]) async throws -> Any {
        // Convert dictionary parameters to the tool's expected parameter type
        let jsonData = try JSONSerialization.data(withJSONObject: parameters)
        
        let decoder = JSONDecoder()
        let typedParameters: T.Parameters
        
        do {
            typedParameters = try decoder.decode(T.Parameters.self, from: jsonData)
        } catch {
            throw LLMToolError.invalidParameters("Failed to decode parameters: \(error.localizedDescription)")
        }
        
        do {
            let result = try await tool.execute(parameters: typedParameters)
            return result
        } catch let toolError as LLMToolError {
            throw toolError
        } catch {
            throw LLMToolError.executionFailed(error.localizedDescription)
        }
    }
}