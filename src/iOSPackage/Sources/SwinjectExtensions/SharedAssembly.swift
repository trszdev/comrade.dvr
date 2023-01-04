import Swinject

public protocol SharedAssembly: Assembly {
  static var shared: Self { get }
  func assembleWithChildren(container: Container) -> [SharedAssembly]
}

public extension SharedAssembly {
  func assemble(container: Container) {
    let assemblies = assembleWithChildren(container: container)
    assemblies.forEach { $0.assemble(container: container) }
  }

  func assembleWithChildren(container: Container) -> [SharedAssembly] {
    assemble(container: container)
    return []
  }
}
