// swift-tools-version:5.5
import PackageDescription

var package = Package(
  name: "iOSPackage",
  defaultLocalization: "en",
  platforms: [.iOS(.v14)]
)

// MARK: - Dependencies

struct ExternalDependency {
  var id = Int.random(in: Int.min...Int.max)
  var target: Target.Dependency
  var package: Package.Dependency

  static let kingfisher = Self(
    target: .product(name: "Kingfisher", package: "Kingfisher"),
    package: .package(url: "https://github.com/onevcat/Kingfisher", "7.0.0"..."8.0.0")
  )

  static let composableArchitecture = Self(
    target: .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    package: .package(url: "https://github.com/pointfreeco/swift-composable-architecture", "0.33.1"..."1.0.0")
  )

  static let swinject = Self(
    target: .product(name: "Swinject", package: "Swinject"),
    package: .package(url: "https://github.com/Swinject/Swinject", "2.8.1"..."3.0.0")
  )

  static let swinjectAutoregistration = Self(
    target: .product(name: "SwinjectAutoregistration", package: "SwinjectAutoregistration"),
    package: .package(url: "https://github.com/Swinject/SwinjectAutoregistration", "2.8.1"..."3.0.0")
  )

  static let util = Self(
    target: .product(name: "Util", package: "UniversalPackage"),
    package: .package(name: "UniversalPackage", path: "../UniversalPackage")
  )
}

// MARK: - Modules

struct Module {
  var name: String
  var moduleDependencies = [Self]()
  var externalDependencies = [ExternalDependency]()
  var resources: [Resource]?
  var isTestTarget = false
  var exclude = [String]()

  static let assets = Self(
    name: "Assets",
    resources: [.process("Resources")],
    exclude: ["L10n.stencil", "ColorAsset.stencil", "ImageAsset.stencil"]
  )

  static let commonUI = Self(name: "CommonUI")

  static let history = Self(
    name: "History",
    moduleDependencies: [.assets],
    externalDependencies: [.composableArchitecture, .util]
  )

  static let settings = Self(
    name: "Settings",
    moduleDependencies: [.assets, .composableArchitectureExtensions, .localizedUtils]
  )

  static let start = Self(
    name: "Start",
    moduleDependencies: [.assets],
    externalDependencies: [.composableArchitecture, .util]
  )

  static let routing = Self(
    name: "Routing",
    moduleDependencies: [.commonUI, .swinjectExtensions, .composableArchitectureExtensions, .settings]
  )

  static let app = Self(
    name: "App",
    moduleDependencies: [
      .routing,
      .commonUI,
      .composableArchitectureExtensions,
      .localizedUtils,
      .settings,
    ]
  )

  static let composableArchitectureExtensions = Self(
    name: "ComposableArchitectureExtensions",
    externalDependencies: [.composableArchitecture, .util]
  )

  static let swinjectExtensions = Self(
    name: "SwinjectExtensions",
    externalDependencies: [.swinject, .swinjectAutoregistration]
  )

  static let localizedUtils = Self(
    name: "LocalizedUtils",
    moduleDependencies: [.assets],
    externalDependencies: [.util]
  )

  static let all: [Self] = [
    .app,
    .assets,
    .commonUI,
    .history,
    .settings,
    .start,
    .routing,
    .composableArchitectureExtensions,
    .swinjectExtensions,
    .localizedUtils,
    .commonTestModule(for: assets),
  ]

  private static func commonTestModule(for module: Self) -> Self {
    Self(name: "\(module.name)Tests", moduleDependencies: [module], isTestTarget: true)
  }
}

// MARK: - Configure package

extension ExternalDependency: Hashable, Identifiable {
  static func == (lhs: ExternalDependency, rhs: ExternalDependency) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Module {
  var target: PackageDescription.Target {
    let moduleDependencies = moduleDependencies.lazy.map(\.name).map(Target.Dependency.init(stringLiteral:))
    let externalDependencies = externalDependencies.map(\.target)
    let dependencies = moduleDependencies + externalDependencies
    if isTestTarget {
      return .testTarget(name: name, dependencies: dependencies, exclude: exclude, resources: resources)
    } else {
      return .target(name: name, dependencies: dependencies, exclude: exclude, resources: resources)
    }
  }
}

let externalDependencies = Set(Module.all.flatMap(\.externalDependencies))
package.dependencies.append(contentsOf: externalDependencies.map(\.package))

for module in Module.all {
  if !module.isTestTarget {
    package.products.append(.library(name: module.name, targets: [module.name]))
  }
  package.targets.append(module.target)
}
