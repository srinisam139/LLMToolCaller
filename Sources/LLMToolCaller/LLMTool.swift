import Foundation

/// A protocol that defines an LLM tool with structured input and output
public protocol LLMTool {
    /// The name of the tool
    static var name: String { get }
    
    /// A description of what the tool does
    static var description: String { get }
    
    /// The parameters expected by this tool
    associatedtype Parameters: Codable
    
    /// The result type returned by this tool
    associatedtype Result: Codable
    
    /// Execute the tool with the given parameters
    /// - Parameter parameters: The structured parameters for the tool
    /// - Returns: The structured result of the tool execution
    /// - Throws: LLMToolError or any other error during execution
    func execute(parameters: Parameters) async throws -> Result
}

/// Errors that can occur during tool execution
public enum LLMToolError: Error, LocalizedError {
    case invalidParameters(String)
    case executionFailed(String)
    case toolNotFound(String)
    case serializationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidParameters(let message):
            return "Invalid parameters: \(message)"
        case .executionFailed(let message):
            return "Execution failed: \(message)"
        case .toolNotFound(let name):
            return "Tool not found: \(name)"
        case .serializationError(let message):
            return "Serialization error: \(message)"
        }
    }
}

/// A tool call request containing the tool name and parameters
public struct LLMToolCall: Codable {
    public let id: String
    public let name: String
    public let parameters: [String: Any]
    
    public init(name: String, parameters: [String: Any], id: String = UUID().uuidString) {
        self.id = id
        self.name = name
        self.parameters = parameters
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let parametersContainer = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .parameters)
        var parametersDict: [String: Any] = [:]
        
        for key in parametersContainer.allKeys {
            if let stringValue = try? parametersContainer.decode(String.self, forKey: key) {
                parametersDict[key.stringValue] = stringValue
            } else if let intValue = try? parametersContainer.decode(Int.self, forKey: key) {
                parametersDict[key.stringValue] = intValue
            } else if let doubleValue = try? parametersContainer.decode(Double.self, forKey: key) {
                parametersDict[key.stringValue] = doubleValue
            } else if let boolValue = try? parametersContainer.decode(Bool.self, forKey: key) {
                parametersDict[key.stringValue] = boolValue
            }
        }
        
        parameters = parametersDict
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        var parametersContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .parameters)
        for (key, value) in parameters {
            let codingKey = DynamicCodingKey(stringValue: key)!
            
            if let stringValue = value as? String {
                try parametersContainer.encode(stringValue, forKey: codingKey)
            } else if let intValue = value as? Int {
                try parametersContainer.encode(intValue, forKey: codingKey)
            } else if let doubleValue = value as? Double {
                try parametersContainer.encode(doubleValue, forKey: codingKey)
            } else if let boolValue = value as? Bool {
                try parametersContainer.encode(boolValue, forKey: codingKey)
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, parameters
    }
}

/// A tool call result containing the original call and the result
public struct LLMToolResult: Codable {
    public let toolCall: LLMToolCall
    public let result: Any
    public let error: String?
    
    public init(toolCall: LLMToolCall, result: Any, error: String? = nil) {
        self.toolCall = toolCall
        self.result = result
        self.error = error
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        toolCall = try container.decode(LLMToolCall.self, forKey: .toolCall)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        
        // For simplicity, decode result as a string first, then try to parse as JSON
        if let resultString = try? container.decode(String.self, forKey: .result) {
            if let data = resultString.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                result = dict
            } else {
                result = resultString
            }
        } else {
            result = [:]
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(toolCall, forKey: .toolCall)
        try container.encodeIfPresent(error, forKey: .error)
        
        // Encode result based on its type
        if let stringResult = result as? String {
            try container.encode(stringResult, forKey: .result)
        } else if let dictResult = result as? [String: Any] {
            // This is a simplified encoding - in production you might want more robust handling
            let jsonData = try JSONSerialization.data(withJSONObject: dictResult)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            try container.encode(jsonString, forKey: .result)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case toolCall = "tool_call"
        case result
        case error
    }
}

/// Dynamic coding key for handling arbitrary dictionary keys
struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}