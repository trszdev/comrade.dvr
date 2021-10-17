// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TestUtil",
  products: [
    .library(name: "TestUtil", targets: ["TestUtil"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "TestUtil",
      dependencies: []
    ),
    .testTarget(
      name: "TestUtilTests",
      dependencies: ["TestUtil"]
    ),
  ]
)
