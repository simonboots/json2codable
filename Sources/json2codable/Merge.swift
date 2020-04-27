

/// Merge two types if possible
///
/// During the parsing phase, it is often not clear what the type of a value exactly is. For example, parsing this array:
/// ```
/// [null, 123]
/// ```
/// Looking at the first value (`null`) it is not clear what the type of the array should be and it is stored as a `.optional(.unknown)` type.
/// Only after the parser sees the second value(`123`), it can attempt to merge the two types (`.optional(.unknown)` and `int`). The final
/// value for the array content is `.optional(.int)`.
///
/// - Parameters:
///   - type1: A `JSONType`
///   - type2: Another `JSONType`
func merge(_ type1: JSONType, _ type2: JSONType) -> Result<JSONType, J2CError> {
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
        // dict1 + dict2 = mergeDicts(dict1, dict2)
        case (.dict(let content1), .dict(let content2)):
            return mergeDicts(content1, content2)
        // array1(T) + array2(S) = array(merge(T, S))
        case (.array(let content1), .array(let content2)):
            return merge(content1, content2).map(JSONType.array)
        default:
            return .failure(.unableToMergeTypes("Unable to merge type \(type1) with \(type2)"))
    }
}

/// Merge dictionaries
///
/// The keys and their types of two dictionaries can be merged together into a single dictionary. This is neccessary if the content type of an array
/// are dictionaries and we need to find a common dictionary type that can store any of the dictionaries in the array. For example:
/// ```
/// [
///     {
///         "commonKey1": true,
///         "commonKey2": 123,
///         "uniqueKey": "someValue",
///     },
///     {
///         "commonKey1": false,
///         "commonKey2": null,
///     }
/// ]
/// ```
/// Here, we have two dictionaries with some overlap. The types of overlapping keys are merged using the `merge` function. Types for unique keys that only
/// exist in some of the dictionaries are automatically changed to `.optional`.
/// - Parameters:
///   - d1: Contents of a `JSONType.dict`
///   - d2: Contents of another `JSONType.dict`
private func mergeDicts(_ d1: [String: JSONType], _ d2: [String: JSONType]) -> Result<JSONType, J2CError> {
    let d1Keys = Set(d1.keys)
    let d2Keys = Set(d2.keys)
    var resultDict: [String: JSONType] = [:]
    
    // Common keys that exist in both dictionaries must have same type or be mergeable
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
    
    // Types for unique keys that exist in only one dictionary are changed to `.optional(T)`
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
