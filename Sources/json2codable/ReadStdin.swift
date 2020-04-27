import Foundation

/// Read from `stdin` and return input as `Data` after stdin is closed
func readStdin() -> Result<Data, J2CError> {
    let data = FileHandle.standardInput.readDataToEndOfFile()
    return .success(data)
}
