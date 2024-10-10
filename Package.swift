// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "keystone-box",
    platforms: [.macOS(.v14)], // Needed on macOS
    dependencies: [
        .package(url: "https://github.com/tomasf/SwiftSCAD.git", from: "0.7.1"),
        .package(url: "https://github.com/tomasf/Keystone.git", branch: "main"),
        .package(url: "https://github.com/tomasf/Helical.git", branch: "main"),
    ],
    targets: [
        .executableTarget(name: "keystone-box", dependencies: ["SwiftSCAD", "Keystone", "Helical"]),
    ]
)
