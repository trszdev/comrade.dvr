// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "MainScreen",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(name: "MainScreen", targets: ["MainScreen"]),
  ],
  dependencies: [
    .package(name: "Assets", path: "../Assets")
  ],
  targets: [
    .target(name: "MainScreen", dependencies: ["Assets"]),
  ]
)
