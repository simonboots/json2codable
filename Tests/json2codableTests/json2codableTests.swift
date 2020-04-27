import XCTest
import class Foundation.Bundle

final class json2codableTests: XCTestCase {
    
    static var allTests = [
        ("testScalars", testScalars),
        ("testArrayInt", testArrayInt),
        ("testNestedDictionary", testNestedDictionary),
        ("testDictionaryInArrayMatchingKeys", testDictionaryInArrayMatchingKeys),
        ("testDictionaryInArrayNotMatchingKeys", testDictionaryInArrayNotMatchingKeys),
        ("testDictionaryInArrayWithNullValues", testDictionaryInArrayWithNullValues),
        ("testBoolToIntMerge", testBoolToIntMerge),
        ("testBoolToFloatMerge", testBoolToFloatMerge),
        ("testIntToFloatMerge", testIntToFloatMerge),
        ("testOptionalMerge", testOptionalMerge),
        ("testSingularizeStructName", testSingularizeStructName),
    ]
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    // MARK: - Tests
    
    
    func testScalars() throws {
        let doc = """
        {
            "bool": true,
            "int": 123,
            "float": 3.1415,
            "string": "Swift is fun"
        }
        """
        let expected = """
        struct NewType: Codable {
            let bool: Bool
            let float: Double
            let int: Int
            let string: String
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }

    func testArrayInt() throws {
        let doc = """
        {
            "array": [123, 456]
        }
        """
        let expected = """
        struct NewType: Codable {
            let array: [Int]
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testNestedDictionary() throws {
        let doc = """
        {
            "nestedDict": {
                "key": "value"
            }
        }
        """
        let expected = """
        struct NewType: Codable {
            let nestedDict: NestedDict
            struct NestedDict: Codable {
                let key: String
            }
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testDictionaryInArrayMatchingKeys() throws {
        let doc = """
        {
            "dictArray": [
                {
                    "key": "value1"
                },
                {
                    "key": "value2"
                }
            ]
        }
        """
        let expected = """
        struct NewType: Codable {
            let dictArray: [DictArray]
            struct DictArray: Codable {
                let key: String
            }
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testDictionaryInArrayNotMatchingKeys() throws {
        let doc = """
        {
            "dictArray": [
                {
                    "key": "value1",
                    "common": true
                },
                {
                    "common": false,
                    "anotherKey": 123
                }
            ]
        }
        """
        let expected = """
        struct NewType: Codable {
            let dictArray: [DictArray]
            struct DictArray: Codable {
                let anotherKey: Int?
                let common: Bool
                let key: String?
            }
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testDictionaryInArrayWithNullValues() throws {
        let doc = """
        {
            "dictArray": [
                {
                    "key": "value1",
                    "common": true
                },
                {
                    "common": false,
                    "key": null
                }
            ]
        }
        """
        let expected = """
        struct NewType: Codable {
            let dictArray: [DictArray]
            struct DictArray: Codable {
                let common: Bool
                let key: String?
            }
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testBoolToIntMerge() throws {
        // `1` and `0` are parsed as `Bool` and can be promoted to `Int` if neccessary.
        let doc = """
        {
            "numberAsBool": 1,
            "mixedArray": [
                1,
                123
            ]
        }
        """
        let expected = """
        struct NewType: Codable {
            let mixedArray: [Int]
            let numberAsBool: Bool
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testBoolToFloatMerge() throws {
        // `1` and `0` are parsed as `Bool` and can be promoted to `Int` if neccessary.
        let doc = """
        {
            "numberAsBool": 1,
            "mixedArray": [
                1,
                123.123
            ]
        }
        """
        let expected = """
        struct NewType: Codable {
            let mixedArray: [Double]
            let numberAsBool: Bool
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testIntToFloatMerge() throws {
        // `1` and `0` are parsed as `Bool` and can be promoted to `Int` if neccessary.
        let doc = """
        {
            "numberAsInt": 2,
            "mixedArray": [
                2,
                123.123
            ]
        }
        """
        let expected = """
        struct NewType: Codable {
            let mixedArray: [Double]
            let numberAsInt: Int
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testOptionalMerge() throws {
        let doc = """
        {
            "mixedArray": [
                123,
                null
            ]
        }
        """
        let expected = """
        struct NewType: Codable {
            let mixedArray: [Int?]
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    func testSingularizeStructName() throws {
        let doc = """
        {
            "pluralNames": [
                {
                    "key": "value"
                }
            ],
            "singularName": {
                "key": "value"
            }
        }
        """
        let expected = """
        struct NewType: Codable {
            let pluralNames: [PluralName]
            struct PluralName: Codable {
                let key: String
            }
            let singularName: SingularName
            struct SingularName: Codable {
                let key: String
            }
        }
        """
        try runTest(jsonDoc: doc, expected: expected)
    }
    
    private func runTest(jsonDoc: String, expected: String, file: StaticString = #file, line: UInt = #line) throws {
        
        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            XCTFail("Requires macOS 10.13 or above")
            return
        }
        
        let binary = productsDirectory.appendingPathComponent("json2codable")

        let process = Process()
        process.executableURL = binary

        let stdoutPipe = Pipe()
        let stdinPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardInput = stdinPipe

        try process.run()
        guard let jsonData = jsonDoc.data(using: .utf8) else {
            XCTFail("Unable to convery json document to Data")
            return
        }
        
        stdinPipe.fileHandleForWriting.write(jsonData)
        stdinPipe.fileHandleForWriting.closeFile()
        process.waitUntilExit()

        let outputData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)

        XCTAssertEqual(
            output?.trimmingCharacters(in: .whitespacesAndNewlines),
            expected.trimmingCharacters(in: .whitespacesAndNewlines),
            file: file,
            line: line
        )
    }
    
}
