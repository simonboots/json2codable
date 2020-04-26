// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "json2codable",
    dependencies: [
    ],
    targets: [
        .target(
            name: "json2codable",
            dependencies: []),
        .testTarget(
            name: "json2codableTests",
            dependencies: ["json2codable"]),
    ]
)
