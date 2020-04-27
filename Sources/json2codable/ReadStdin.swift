import Foundation

func readStdin() -> Result<Data, RecodeError> {
    let data = FileHandle.standardInput.readDataToEndOfFile()
    return .success(data)
}
