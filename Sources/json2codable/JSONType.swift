indirect enum JSONType: Equatable {
    case unknown
    case bool
    case int
    case double
    case string
    case array(JSONType)
    case dict([String: JSONType])
    case optional(JSONType)
}

extension JSONType: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .bool:
            return "bool"
        case .int:
            return "int"
        case .double:
            return "double"
        case .string:
            return "string"
        case .array(let content):
            return "array(\(content.description))"
        case .dict(let content):
            let contentString = content
                .map { (key: String, value: JSONType) -> String in
                    return "\(key): \(value.description)"
                }
                .joined(separator: ",\n")
            return "dict(\(contentString))"
        case .optional(let content):
            return "optional(\(content.description))"
        }
    }
}
