// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LLMToolCaller",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "LLMToolCaller",
            targets: ["LLMToolCaller"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "LLMToolCaller",
            dependencies: []),
        .testTarget(
            name: "LLMToolCallerTests",
            dependencies: ["LLMToolCaller"]),
        .executableTarget(
            name: "LLMToolCallerExample",
            dependencies: [
                "LLMToolCaller",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ])
    ]
)