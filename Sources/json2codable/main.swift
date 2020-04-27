import Foundation

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
