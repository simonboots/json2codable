func render(type: JSONType) -> Result<String, RecodeError> {
    // Root level type must be array or dictionary
    // Only root level dictionaries can be rendered into a Codable struct
    
    switch type {
    case .array(let arrayType):
        return render(type: arrayType)
    case .dict:
        var string = ""
        string += render(type, indentLevel: 0).def
        return .success(string)
    default:
        return .failure(.invalidRootType)
    }
}

private func render(_ type: JSONType, indentLevel i: Int, nameHint: String? = nil) -> (type: String, def: String) {
    switch type {
    case .unknown:
        return (type: "Unknown", def: "")
    case .bool:
        return (type: "Bool", def: "")
    case .int:
        return (type: "Int", def: "")
    case .float:
        return (type: "Float", def: "")
    case .string:
        return (type: "String", def: "")
    case .array(let arrayType):
        var r = render(arrayType, indentLevel: i, nameHint: nameHint)
        r.type = "[" + r.type + "]"
        return r
    case .optional(let optionalType):
        var r = render(optionalType, indentLevel: i, nameHint: nameHint)
        r.type += "?"
        return r
    case .dict(let dictContent):
        let structName = nameHint?.capitalizedFirst() ?? "NewType"
        var def = indent(i) + "struct \(structName): Codable {\n"

        dictContent
            .sorted(by: { $0.key < $1.key })
            .forEach { (key, value) in
                let r = render(value, indentLevel: i + 1, nameHint: key)
                def += indent(i + 1) + "let \(key): \(r.type)\n"
                def += r.def
            }
        
        def += indent(i) + "}\n"
        
        return (type: structName, def: def)
    }
}

private func indent(_ level: Int) -> String {
    return String(repeating: " ", count: level * 4)
}
