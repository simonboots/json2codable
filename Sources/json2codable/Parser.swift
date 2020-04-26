import Foundation

func parse(object: Any) -> Result<JSONType, RecodeError> {
    
    if object is Bool {
        return .success(.bool)
    }
    
    if object is Int {
        return .success(.int)
    }
    
    if object is Float {
        return .success(.float)
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
            
            let refineResult = refine(type, parsedType)
            guard case .success(let refinedType) = refineResult else {
                return refineResult
            }
            type = refinedType
        }
        return .success(.array(type))
    }
    
    return .failure(.unknownType)
}
