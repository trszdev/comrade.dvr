public extension AKContainer {
  func registerMany(assemblies: [AKAssembly]) {
    for assembly in assemblies {
      assembly.assemble(container: self)
    }
  }
}
