// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AutocontainerKit",
    products: [
        .library(
            name: "AutocontainerKit",
            targets: ["AutocontainerKit"]),
    ],
    targets: [
        .target(
            name: "AutocontainerKit",
            dependencies: []),
        .testTarget(
            name: "AutocontainerKitTests",
            dependencies: ["AutocontainerKit"]),
    ]
)
