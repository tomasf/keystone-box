// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "keystone-box",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/tomasf/Keystone.git", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/tomasf/Helical.git", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "keystone-box",
            dependencies: ["Cadova", "Keystone", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
