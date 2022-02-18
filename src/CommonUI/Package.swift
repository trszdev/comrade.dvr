// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "CommonUI",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(name: "CommonUI", targets: ["CommonUI"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "CommonUI", dependencies: []),
  ]
)
