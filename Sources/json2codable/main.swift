import Foundation

let jsonDocument = """
{
    "name": "Barney",
    "age": 42,
    "pins": [
        123,
        567,
        null
    ],
    "someArray": [
        {
            "key": "value"
        },
        {
            "key": null,
            "key2": false
        }
    ]
}
"""

func stringToData(_ string: String) -> Result<Data, RecodeError> {
    guard let data = string.data(using: .utf8) else {
        return .failure(.stdinReadError)
    }
    
    return .success(data)
}

//let result = readStdin()
let result = stringToData(jsonDocument)
    .flatMap(deserialize(data:))
    .flatMap(parse(object:))
    .flatMap(render(type:))

switch result {
case .failure(let error):
    print("ERROR: \(error)")
case .success(let type):
    print(type)
}
