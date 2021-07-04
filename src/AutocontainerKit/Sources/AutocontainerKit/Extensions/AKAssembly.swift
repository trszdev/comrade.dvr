public extension AKAssembly {
  var hashContainer: AKHashContainer {
    let result = AKHashContainer()
    result.transient.autoregister(AKLocator.self) { [weak result] in
      result!
    }
    assemble(container: result)
    return result
  }
}

public extension Array where Element: AKAssembly {
  var hashContainer: AKHashContainer {
    let result = AKHashContainer()
    result.transient.autoregister(AKLocator.self) { [weak result] in
      result!
    }
    result.registerMany(assemblies: self)
    return result
  }
}
