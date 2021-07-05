public extension AKAssembly {
  var hashContainer: AKHashContainer {
    let result = AKHashContainer()
    result.transient.autoregister(AKLocator.self) { [weak result] in
      result!
    }
    assemble(container: result)
    return result
  }

  var mockContainer: AKMockContainer {
    let result = AKMockContainer()
    result.innerContainer.transient.autoregister(AKLocator.self) { [weak result] in
      result!
    }
    result.transient.autoregister(AKLocator.self) { [weak result] in
      result!
    }
    assemble(container: result.innerContainer)
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

  var mockContainer: AKMockContainer {
    let result = AKMockContainer()
    result.innerContainer.transient.autoregister(AKLocator.self) { [weak result] in
      result!
    }
    result.transient.autoregister(AKLocator.self) { [weak result] in
      result!
    }
    result.innerContainer.registerMany(assemblies: self)
    return result
  }
}
