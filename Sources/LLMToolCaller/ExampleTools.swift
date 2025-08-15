import Foundation

/// Example weather tool implementation
public struct WeatherTool: LLMTool {
    public static let name = "get_weather"
    public static let description = "Get current weather information for a specified location"
    
    public struct Parameters: Codable {
        public let location: String
        public let unit: String?
        public let includeHourly: Bool?
        
        public init(location: String, unit: String? = nil, includeHourly: Bool? = nil) {
            self.location = location
            self.unit = unit
            self.includeHourly = includeHourly
        }
        
        enum CodingKeys: String, CodingKey {
            case location
            case unit
            case includeHourly = "include_hourly"
        }
    }
    
    public struct Result: Codable {
        public let location: String
        public let temperature: Double
        public let condition: String
        public let humidity: Int
        public let windSpeed: Double
        public let unit: String
        public let hourlyForecast: [HourlyForecast]?
        
        enum CodingKeys: String, CodingKey {
            case location
            case temperature
            case condition
            case humidity
            case windSpeed = "wind_speed"
            case unit
            case hourlyForecast = "hourly_forecast"
        }
    }
    
    public struct HourlyForecast: Codable {
        public let time: String
        public let temperature: Double
        public let condition: String
        
        public init(time: String, temperature: Double, condition: String) {
            self.time = time
            self.temperature = temperature
            self.condition = condition
        }
    }
    
    public init() {}
    
    public func execute(parameters: Parameters) async throws -> Result {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let unit = parameters.unit?.lowercased() ?? "celsius"
        
        // Mock weather data
        let baseTemp = unit == "fahrenheit" ? 72.0 : 22.0
        let temp = baseTemp + Double.random(in: -10...10)
        
        let conditions = ["Sunny", "Cloudy", "Partly Cloudy", "Rainy", "Snowy"]
        let condition = conditions.randomElement()!
        
        var hourlyForecast: [HourlyForecast]? = nil
        if parameters.includeHourly == true {
            hourlyForecast = (0..<24).map { hour in
                let hourTemp = temp + Double.random(in: -3...3)
                return HourlyForecast(
                    time: String(format: "%02d:00", hour),
                    temperature: hourTemp,
                    condition: conditions.randomElement()!
                )
            }
        }
        
        return Result(
            location: parameters.location,
            temperature: temp,
            condition: condition,
            humidity: Int.random(in: 30...80),
            windSpeed: Double.random(in: 0...25),
            unit: unit,
            hourlyForecast: hourlyForecast
        )
    }
}

/// Example calculator tool implementation
public struct CalculatorTool: LLMTool {
    public static let name = "calculator"
    public static let description = "Perform basic mathematical operations on numbers"
    
    public struct Parameters: Codable {
        public let operation: Operation
        public let operands: [Double]
        
        public init(operation: Operation, operands: [Double]) {
            self.operation = operation
            self.operands = operands
        }
    }
    
    public enum Operation: String, Codable, CaseIterable {
        case add = "add"
        case subtract = "subtract"
        case multiply = "multiply"
        case divide = "divide"
        case power = "power"
        case sqrt = "sqrt"
        case sin = "sin"
        case cos = "cos"
        case tan = "tan"
    }
    
    public struct Result: Codable {
        public let operation: Operation
        public let operands: [Double]
        public let result: Double
        public let expression: String
        
        public init(operation: Operation, operands: [Double], result: Double, expression: String) {
            self.operation = operation
            self.operands = operands
            self.result = result
            self.expression = expression
        }
    }
    
    public init() {}
    
    public func execute(parameters: Parameters) async throws -> Result {
        let operands = parameters.operands
        let operation = parameters.operation
        
        guard !operands.isEmpty else {
            throw LLMToolError.invalidParameters("At least one operand is required")
        }
        
        let result: Double
        let expression: String
        
        switch operation {
        case .add:
            result = operands.reduce(0, +)
            expression = operands.map { "\($0)" }.joined(separator: " + ") + " = \(result)"
            
        case .subtract:
            guard operands.count >= 2 else {
                throw LLMToolError.invalidParameters("Subtraction requires at least 2 operands")
            }
            result = operands.dropFirst().reduce(operands[0], -)
            expression = operands.map { "\($0)" }.joined(separator: " - ") + " = \(result)"
            
        case .multiply:
            result = operands.reduce(1, *)
            expression = operands.map { "\($0)" }.joined(separator: " × ") + " = \(result)"
            
        case .divide:
            guard operands.count >= 2 else {
                throw LLMToolError.invalidParameters("Division requires at least 2 operands")
            }
            guard !operands.dropFirst().contains(0) else {
                throw LLMToolError.executionFailed("Division by zero")
            }
            result = operands.dropFirst().reduce(operands[0], /)
            expression = operands.map { "\($0)" }.joined(separator: " ÷ ") + " = \(result)"
            
        case .power:
            guard operands.count == 2 else {
                throw LLMToolError.invalidParameters("Power operation requires exactly 2 operands")
            }
            result = pow(operands[0], operands[1])
            expression = "\(operands[0])^\(operands[1]) = \(result)"
            
        case .sqrt:
            guard operands.count == 1 else {
                throw LLMToolError.invalidParameters("Square root requires exactly 1 operand")
            }
            guard operands[0] >= 0 else {
                throw LLMToolError.executionFailed("Cannot take square root of negative number")
            }
            result = sqrt(operands[0])
            expression = "√\(operands[0]) = \(result)"
            
        case .sin:
            guard operands.count == 1 else {
                throw LLMToolError.invalidParameters("Sine requires exactly 1 operand")
            }
            result = sin(operands[0])
            expression = "sin(\(operands[0])) = \(result)"
            
        case .cos:
            guard operands.count == 1 else {
                throw LLMToolError.invalidParameters("Cosine requires exactly 1 operand")
            }
            result = cos(operands[0])
            expression = "cos(\(operands[0])) = \(result)"
            
        case .tan:
            guard operands.count == 1 else {
                throw LLMToolError.invalidParameters("Tangent requires exactly 1 operand")
            }
            result = tan(operands[0])
            expression = "tan(\(operands[0])) = \(result)"
        }
        
        return Result(
            operation: operation,
            operands: operands,
            result: result,
            expression: expression
        )
    }
}

/// Example text processing tool implementation
public struct TextProcessorTool: LLMTool {
    public static let name = "text_processor"
    public static let description = "Process text with various operations like counting, transforming, and analyzing"
    
    public struct Parameters: Codable {
        public let text: String
        public let operations: [Operation]
        
        public init(text: String, operations: [Operation]) {
            self.text = text
            self.operations = operations
        }
    }
    
    public enum Operation: String, Codable, CaseIterable {
        case wordCount = "word_count"
        case characterCount = "character_count"
        case uppercase = "uppercase"
        case lowercase = "lowercase"
        case reverse = "reverse"
        case removeSpaces = "remove_spaces"
        case sentenceCount = "sentence_count"
    }
    
    public struct Result: Codable {
        public let originalText: String
        public let results: [String: Any]
        
        enum CodingKeys: String, CodingKey {
            case originalText = "original_text"
            case results
        }
        
        public init(originalText: String, results: [String: Any]) {
            self.originalText = originalText
            self.results = results
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            originalText = try container.decode(String.self, forKey: .originalText)
            
            // Simplified decoding for results dictionary
            let resultsContainer = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .results)
            var resultsDict: [String: Any] = [:]
            
            for key in resultsContainer.allKeys {
                if let stringValue = try? resultsContainer.decode(String.self, forKey: key) {
                    resultsDict[key.stringValue] = stringValue
                } else if let intValue = try? resultsContainer.decode(Int.self, forKey: key) {
                    resultsDict[key.stringValue] = intValue
                }
            }
            
            results = resultsDict
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(originalText, forKey: .originalText)
            
            var resultsContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .results)
            for (key, value) in results {
                let codingKey = DynamicCodingKey(stringValue: key)!
                
                if let stringValue = value as? String {
                    try resultsContainer.encode(stringValue, forKey: codingKey)
                } else if let intValue = value as? Int {
                    try resultsContainer.encode(intValue, forKey: codingKey)
                }
            }
        }
    }
    
    public init() {}
    
    public func execute(parameters: Parameters) async throws -> Result {
        let text = parameters.text
        var results: [String: Any] = [:]
        
        for operation in parameters.operations {
            switch operation {
            case .wordCount:
                let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
                results["word_count"] = words.count
                
            case .characterCount:
                results["character_count"] = text.count
                
            case .uppercase:
                results["uppercase"] = text.uppercased()
                
            case .lowercase:
                results["lowercase"] = text.lowercased()
                
            case .reverse:
                results["reverse"] = String(text.reversed())
                
            case .removeSpaces:
                results["remove_spaces"] = text.replacingOccurrences(of: " ", with: "")
                
            case .sentenceCount:
                let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?")).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                results["sentence_count"] = sentences.count
            }
        }
        
        return Result(originalText: text, results: results)
    }
}