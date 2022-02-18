// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Assets",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "Assets",
      targets: ["Assets"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Assets",
      dependencies: [],
      exclude: ["L10n.stencil", "ColorAsset.stencil", "ImageAsset.stencil"],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "AssetsTests",
      dependencies: ["Assets"]
    ),
  ],
  swiftLanguageVersions: [.version("5.3")]
)
