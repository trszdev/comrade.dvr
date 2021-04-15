public extension AKAssembly {
  var hashContainer: AKHashContainer {
    let result = AKHashContainer()
    result.singleton.autoregister(AKLocator.self, value: result)
    assemble(container: result)
    return result
  }
}

public extension Array where Element: AKAssembly {
  var hashContainer: AKHashContainer {
    let result = AKHashContainer()
    result.singleton.autoregister(AKLocator.self, value: result)
    result.registerMany(assemblies: self)
    return result
  }
}
