import Foundation

func deserialize(data: Data) -> Result<Any, RecodeError> {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return .success(jsonObject)
    } catch {
        return .failure(.deserializationError(error))
    }
}
