func merge(_ type1: JSONType, _ type2: JSONType) -> Result<JSONType, RecodeError> {
    guard type1 != type2 else { return .success(type1) }
    
    switch (type1, type2) {
        // Int + Bool = Int
        case (.int, .bool),
             (.bool, .int):
            return .success(.int)
        // Double + Bool = Double
        case (.double, .bool),
             (.bool, .double):
            return .success(.double)
        // Double + Int = Double
        case (.double, .int),
             (.int, .double):
            return .success(.double)
        // unknown + T = T
        case (.unknown, let other),
             (let other, .unknown):
            return .success(other)
        // optional(T) + optional(S) = optional(merge(T,S))
        case (.optional(let optionalType1), .optional(let optionalType2)):
            return merge(optionalType1, optionalType2).map(JSONType.optional)
        // optional(T) + S = optional(merge(T,S))
        case (.optional(let optionalType), let type),
             (let type, .optional(let optionalType)):
            return merge(type, optionalType).map(JSONType.optional)
        // dict1 + dict2
        case (.dict(let content1), .dict(let content2)):
            return mergeDicts(content1, content2)
        case (.array(let content1), .array(let content2)):
            return merge(content1, content2).map(JSONType.array)
        default:
            return .failure(.unableToMergeTypes("Unable to merge type \(type1) with \(type2)"))
    }
}

private func mergeDicts(_ d1: [String: JSONType], _ d2: [String: JSONType]) -> Result<JSONType, RecodeError> {
    let d1Keys = Set(d1.keys)
    let d2Keys = Set(d2.keys)
    var resultDict: [String: JSONType] = [:]
    
    // Keys that exist in both dictionaries must have same type or be mergeable
    let commonKeys = d1Keys.intersection(d2Keys)
    for key in commonKeys {
        guard let d1Type = d1[key], let d2Type = d2[key] else {
            return .failure(.internalInconsistencyError)
        }
        
        let result = merge(d1Type, d2Type)
        guard case .success(let mergedType) = result else {
            return result
        }
        
        resultDict[key] = mergedType
    }
    
    // Types for keys that exist in only one dictionary are promoted to optional
    let uniqueKeys = d1Keys.union(d2Keys).subtracting(commonKeys)
    for key in uniqueKeys {
        guard let type = d1[key] ?? d2[key] else {
            return .failure(.internalInconsistencyError)
        }
        
        let result = merge(.optional(.unknown), type)
        guard case .success(let mergedType) = result else {
            return result
        }
        resultDict[key] = mergedType
    }
    
    return .success(.dict(resultDict))
}
