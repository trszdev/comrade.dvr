// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "HistoryScreen",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(name: "HistoryScreen", targets: ["HistoryScreen"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "HistoryScreen", dependencies: []),
  ]
)
