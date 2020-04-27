import Foundation

/// json2codable main function
///
/// `json2codable` runs through three stages:
/// - Deserializing: Deserializes the JSON document into an `Any` type using `JSONSerialization`
/// - Parsing: The `Any` type is parsed into a `JSONType` value.
/// - Rendering: The `JSONType` is rendered as a new Swift `struct` type
func main() {
    let result = readStdin()
        .flatMap(deserialize(data:))
        .flatMap(parse(object:))
        .flatMap(render(type:))
    
    switch result {
    case .failure(let error):
        print("Error: \(error)")
    case .success(let type):
        print(type)
    }
}

main()
