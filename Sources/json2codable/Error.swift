enum J2CError: Error {
    case stdinReadError
    case deserializationError(Error)
    case unknownType
    case unableToMergeTypes(String)
    case invalidRootType
    case internalInconsistencyError
}
