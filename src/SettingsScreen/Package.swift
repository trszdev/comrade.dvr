// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "SettingsScreen",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(name: "SettingsScreen", targets: ["SettingsScreen"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "SettingsScreen", dependencies: []),
  ]
)
