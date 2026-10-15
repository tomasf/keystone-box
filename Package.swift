// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "keystone-box",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", branch: "dev"),
        .package(url: "https://github.com/tomasf/Keystone.git", branch: "dev"),
        .package(url: "https://github.com/tomasf/Helical.git", .upToNextMinor(from: "1.1.0"))
    ],
    targets: [
        .executableTarget(
            name: "keystone-box",
            dependencies: ["Cadova", "Keystone", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
