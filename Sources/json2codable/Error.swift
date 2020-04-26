enum RecodeError: Error {
    case stdinReadError
    case deserializationError(Error)
    case unknownType
    case unableToRefineTypes(String)
    case invalidRootType
    case internalInconsistencyError
}
