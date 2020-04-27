/// The rendered representation of a `JSONType`
///
/// - `name` is the name of the type, e.g. `[Int?]`
/// - `def` is the definition of the type if one exists (only used for dictionaries)
typealias RenderedType = (name: String, def: String)

/// Render a `JSONType` to a String (Swift struct)
///
/// Only `.array` or `.dict` values can be rendered.
/// `.array` is unwrapped until a `.dict` is found. That dictionary then forms the new root type of the final Swift struct.
///  JSON documents with an array root type are expected to be decoded to a Swift type wrapped into an array
///  (e.g.: `JSONDecoder().decode([SomeType].self, from: jsonData)`)
/// - Parameter type: A `JSONType` value. Only `.array` or `.dict` values are allowed.
func render(type: JSONType) -> Result<String, J2CError> {
    switch type {
    case .array(let arrayType):
        return render(type: arrayType)
    case .dict:
        return .success(render(type, indentLevel: 0).def)
    default:
        return .failure(.invalidRootType)
    }
}

/// Render a `JSONType` as a `RenderedType`
/// - Parameters:
///   - type: The `JSONType`
///   - indentLevel: The indentation level
///   - nameHint: Name hint of what a new type could be called (used for dictionaries)
private func render(_ type: JSONType, indentLevel i: Int, nameHint: String? = nil) -> RenderedType {
    switch type {
    case .unknown:
        return (name: "Unknown", def: "")
    case .bool:
        return (name: "Bool", def: "")
    case .int:
        return (name: "Int", def: "")
    case .double:
        return (name: "Double", def: "")
    case .string:
        return (name: "String", def: "")
    case .array(let arrayType):
        var r = render(arrayType, indentLevel: i, nameHint: nameHint)
        r.name = "[" + r.name + "]"
        return r
    case .optional(let optionalType):
        var r = render(optionalType, indentLevel: i, nameHint: nameHint)
        r.name += "?"
        return r
    case .dict(let dictContent):
        let structName = nameHint?.toTypeName() ?? "NewType"
        var def = indent(i) + "struct \(structName): Codable {\n"

        dictContent
            .sorted(by: { $0.key < $1.key })
            .forEach { (key, value) in
                let r = render(value, indentLevel: i + 1, nameHint: key)
                def += indent(i + 1) + "let \(key): \(r.name)\n"
                def += r.def
            }
        
        def += indent(i) + "}\n"
        
        return (name: structName, def: def)
    }
}

private func indent(_ level: Int) -> String {
    return String(repeating: " ", count: level * 4)
}

extension String {
    func toTypeName() -> String {
        return singularize().capitalizedFirst()
    }
}
