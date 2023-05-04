// swift-tools-version:5.5
import PackageDescription

var package = Package(
  name: "UniversalPackage",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
    .tvOS(.v9),
    .watchOS(.v2),
  ]
)

// MARK: - Dependencies

struct ExternalDependency {
  var id = Int.random(in: Int.min...Int.max)
  var target: Target.Dependency
  var package: Package.Dependency
}

// MARK: - Modules

struct Module {
  var name: String
  var moduleDependencies = [Self]()
  var externalDependencies = [ExternalDependency]()
  var resources: [Resource]?
  var isTestTarget = false

  static let util = Self(name: "Util")

  static let all: [Self] = [
    .util,
    .commonTestModule(for: util),
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

let externalDependencies = Set(Module.all.flatMap(\.externalDependencies))
package.dependencies.append(contentsOf: externalDependencies.map(\.package))

for module in Module.all {
  if !module.isTestTarget {
    package.products.append(.library(name: module.name, targets: [module.name]))
  }
  let moduleDependencies = module.moduleDependencies.lazy.map(\.name).map(Target.Dependency.init(stringLiteral:))
  let externalDependencies = module.externalDependencies.map(\.target)
  let dependencies = moduleDependencies + externalDependencies
  package.targets.append(
    module.isTestTarget ?
      .testTarget(name: module.name, dependencies: dependencies) :
        .target(name: module.name, dependencies: dependencies, resources: module.resources)
  )
}
