// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "keystone-box",
    dependencies: [
        .package(url: "https://github.com/tomasf/SwiftSCAD.git", .upToNextMinor(from: "0.8.1")),
        .package(url: "https://github.com/tomasf/Keystone.git", branch: "main"),
        .package(url: "https://github.com/tomasf/Helical.git", .upToNextMinor(from: "0.1.1")),
    ],
    targets: [
        .executableTarget(name: "keystone-box", dependencies: ["SwiftSCAD", "Keystone", "Helical"]),
    ]
)
