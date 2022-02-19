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
    .package(url: "https://github.com/Swinject/Swinject", from: "2.8.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.33.1"),
    .package(name: "Util", path: "../Util"),
    .package(name: "Assets", path: "../Assets"),
  ],
  targets: [
    .target(
      name: "SettingsScreen",
      dependencies: [
        .product(name: "Util", package: "Util"),
        // .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Assets", package: "Assets"),
      ]
    ),
  ]
)
