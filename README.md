# JSON2Codable

JSON2Codable is a simple command-line tool that reads a JSON document from stdin and prints out a new Codable-conforming Swift struct that matches the structure of the JSON document.

## Example

```
$ cat colors.json
{
  "colors": [
    {
      "color": "red",
      "category": "hue",
      "type": "primary",
      "code": {
        "rgba": [255,0,0,1],
        "hex": "#FF0"
      }
    },
    {
      "color": "blue",
      "category": "hue",
      "type": "primary",
      "code": {
        "rgba": [0,0,255,1],
        "hex": "#00F"
      }
    }
  ]
}

$ cat colors.json | json2codable
struct NewType: Codable {
    let colors: [Color]
    struct Color: Codable {
        let category: String
        let code: Code
        struct Code: Codable {
            let hex: String
            let rgba: [Int]
        }
        let color: String
        let type: String
    }
}
```

## Known issues
-  Heterogeneous types in arrays are currently not supported (e.g `[123, "string"]`) unless the types can be "merged", for example `Int` can be promoted to `Double` and any type can become an `Optional` if a `null` is present in the array.
- If the root type of the JSON document is an array, it is unwrapped until a dictionary is found. That dictionary forms the new root type of the final Swift struct. JSON documents with an array root type are expected to be decoded to a Swift type wrapped in an array (e.g. `JSONDecoder().decode([SomeType].self, from: jsonData)`)

