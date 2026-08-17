// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "TrackyTock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "TrackyTock",
            targets: ["TrackyTock"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "TrackyTock",
            dependencies: [],
            path: "Sources/TrackyTock",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
