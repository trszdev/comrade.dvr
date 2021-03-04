// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "CameraKit",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "CameraKit",
      targets: ["CameraKit"]
    ),
  ],
  targets: [
    .target(
      name: "CameraKit",
      dependencies: []
    ),
    .testTarget(
      name: "CameraKitTests",
      dependencies: ["CameraKit"]
    ),
  ]
)
