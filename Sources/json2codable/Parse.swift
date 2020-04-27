import Foundation

func parse(object: Any) -> Result<JSONType, RecodeError> {
    
    if object is Bool {
        return .success(.bool)
    }
    
    if object is Int {
        return .success(.int)
    }
    
    if object is Double {
        return .success(.double)
    }
    
    if object is String {
        return .success(.string)
    }
    
    if object is NSNull {
        return .success(.optional(.unknown))
    }
    
    if let dict = object as? [String: Any] {
        var resultDict = [String: JSONType]()
        for element in dict {
            let result = parse(object: element.value)
            guard case .success(let type) = result else {
                return result
            }
            resultDict[element.key] = type
        }
        
        return .success(.dict(resultDict))
    }
    
    if let array = object as? [Any] {
        var type: JSONType = .unknown
        for element in array {
            let parseResult = parse(object: element)
            guard case .success(let parsedType) = parseResult else {
                return parseResult
            }
            
            let mergeResult = merge(type, parsedType)
            guard case .success(let mergedType) = mergeResult else {
                return mergeResult
            }
            type = mergedType
        }
        return .success(.array(type))
    }
    
    return .failure(.unknownType)
}
