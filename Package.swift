// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSimpleChatGPT",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "WWSimpleChatGPT", targets: ["WWSimpleChatGPT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWNetworking.git", from: "1.5.1"),
    ],
    targets: [
        .target(name: "WWSimpleChatGPT", dependencies: ["WWNetworking"], resources: [.copy("Privacy")])
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
