import Foundation

/// Deserialize a JSON document to an `Any` type
/// - Parameter data: The JSON document as a `Data` value
func deserialize(data: Data) -> Result<Any, J2CError> {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return .success(jsonObject)
    } catch {
        return .failure(.deserializationError(error))
    }
}
