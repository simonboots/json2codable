/// This type contains the parsed JSON document
///
/// Notes:
/// * `unknown` is not expected to be used in the final value
/// * A `null` value in a JSON document is stored as an `.optional(.unknown)` until it is merged with another known type
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
                .map { "\($0): \($1.description)" }
                .joined(separator: ",\n")
            return "dict(\(contentString))"
        case .optional(let content):
            return "optional(\(content.description))"
        }
    }
}
