// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Accessibility",
  products: [
    .library(name: "Accessibility", targets: ["Accessibility"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Accessibility", dependencies: []),
  ]
)
