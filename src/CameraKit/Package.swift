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
  dependencies: [
    .package(path: "../AutocontainerKit"),
  ],
  targets: [
    .target(
      name: "CameraKit",
      dependencies: ["AutocontainerKit"]
    ),
    .testTarget(
      name: "CameraKitTests",
      dependencies: ["CameraKit"]
    ),
  ]
)
