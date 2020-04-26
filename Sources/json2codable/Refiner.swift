func refine(_ type1: JSONType, _ type2: JSONType) -> Result<JSONType, RecodeError> {
    guard type1 != type2 else { return .success(type1) }
    
    switch (type1, type2) {
        // unknown + T = T
        case (.unknown, let other),
             (let other, .unknown):
            return .success(other)
        // optional(T) + optional(S) = optional(refine(T,S))
        case (.optional(let optionalType1), .optional(let optionalType2)):
            return refine(optionalType1, optionalType2).map(JSONType.optional)
        // optional(T) + S = optional(refine(T,S))
        case (.optional(let optionalType), let type),
             (let type, .optional(let optionalType)):
            return refine(type, optionalType).map(JSONType.optional)
        // dict1 + dict2
        case (.dict(let content1), .dict(let content2)):
            return refineDicts(content1, content2)
        default:
            return .failure(.unableToRefineTypes("Unable to refine types \(type1) and \(type2)"))
    }
}

private func refineDicts(_ d1: [String: JSONType], _ d2: [String: JSONType]) -> Result<JSONType, RecodeError> {
    let d1Keys = Set(d1.keys)
    let d2Keys = Set(d2.keys)
    var resultDict: [String: JSONType] = [:]
    
    // Keys that exist in both dictionaries must have same type or be refineable
    let commonKeys = d1Keys.intersection(d2Keys)
    for key in commonKeys {
        guard let d1Type = d1[key], let d2Type = d2[key] else {
            return .failure(.internalInconsistencyError)
        }
        
        let result = refine(d1Type, d2Type)
        guard case .success(let refinedType) = result else {
            return result
        }
        
        resultDict[key] = refinedType
    }
    
    // Types for keys that exist in only one dictionary are promoted to optional
    let uniqueKeys = d1Keys.union(d2Keys).subtracting(commonKeys)
    for key in uniqueKeys {
        guard let type = d1[key] ?? d2[key] else {
            return .failure(.internalInconsistencyError)
        }
        
        let result = refine(.optional(.unknown), type)
        guard case .success(let refinedType) = result else {
            return result
        }
        resultDict[key] = refinedType
    }
    
    return .success(.dict(resultDict))
}
