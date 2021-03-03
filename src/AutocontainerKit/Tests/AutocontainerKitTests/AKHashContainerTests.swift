// swiftlint:disable nesting
import XCTest
@testable import AutocontainerKit

final class AKHashContainerTests: XCTestCase {
  func makeContainer() -> AKHashContainer {
    AKHashContainer()
  }

  func testNoThrowsWhenMissing() {
    let container = makeContainer()
    container.asserts = false
    XCTAssertNoThrow(container.resolve(Int.self))
    XCTAssertNil(container.resolve(Int.self))
  }

  func testSample() {
    struct Sample { let locator: AKLocator }
    let container = makeContainer()
    container.singleton.autoregister(AKLocator.self, value: container)
    container.transient.autoregister(construct: Sample.init)
    let resolved = container.resolve(Sample.self)!
    XCTAssertEqual(String(describing: container), String(describing: resolved.locator))
  }

  func testReregisterOverwrites() {
    struct Sample { let value: Int }
    let container = makeContainer()
    container.asserts = false
    container.singleton.autoregister(value: Sample(value: 1))
    container.singleton.autoregister(value: Sample(value: 2))
    let resolved = container.resolve(Sample.self)!
    XCTAssertEqual(resolved.value, 2)
  }

  func testSingleton() {
    struct Sample { let value = arc4random() }
    let container = makeContainer()
    let instance = Sample()
    container.singleton.autoregister(value: instance)
    let resolved = container.resolve(Sample.self)!
    let resolved2 = container.resolve(Sample.self)!
    XCTAssertEqual(resolved.value, resolved2.value)
  }

  func testTransient() {
    struct Sample { let value = arc4random() }
    let container = makeContainer()
    container.transient.autoregister(construct: Sample.init)
    let resolved = container.resolve(Sample.self)!
    let resolved2 = container.resolve(Sample.self)!
    XCTAssertNotEqual(resolved.value, resolved2.value)
  }

  func testExampleParameters() {
    struct Service {}
    struct Service2 {}
    struct Component {
      struct Dependencies {
        let service: Service
        let service2: Service2

        func makeComponent(value: Int) -> Component {
          Component(value: value, dependencies: self)
        }
      }
      let value: Int
      let dependencies: Dependencies
    }
    let container = makeContainer()
    container.transient.autoregister(construct: Service.init)
    container.singleton.autoregister(value: Service2())
    container.transient.autoregister(construct: Component.Dependencies.init)
    let component = container.resolve(Component.Dependencies.self)!.makeComponent(value: 1)
    XCTAssertEqual(component.value, 1)
  }

  func testExampleCycle() {
    struct Dependency {}
    class ServiceA {
      struct Dependencies {
        let dependency: Dependency
      }
      let dependencies: Dependencies
      init(dependencies: Dependencies) {
        self.dependencies = dependencies
      }
      var serviceB: ServiceB?
    }
    class ServiceB {
      struct Dependencies {
        let dependency: Dependency
      }
      let dependencies: Dependencies
      init(dependencies: Dependencies) {
        self.dependencies = dependencies
      }
      var serviceA: ServiceA?
    }
    struct ServicesBuilder {
      let serviceADependencies: ServiceA.Dependencies
      let serviceBDependencies: ServiceB.Dependencies
      func makeServices() -> (ServiceA, ServiceB) {
        let serviceA = ServiceA(dependencies: serviceADependencies)
        let serviceB = ServiceB(dependencies: serviceBDependencies)
        serviceA.serviceB = serviceB
        serviceB.serviceA = serviceA
        return (serviceA, serviceB)
      }
    }
    let container = makeContainer()
    container.transient.autoregister(construct: Dependency.init)
    container.transient.autoregister(construct: ServiceA.Dependencies.init)
    container.transient.autoregister(construct: ServiceB.Dependencies.init)
    container.transient.autoregister(construct: ServicesBuilder.init(serviceADependencies:serviceBDependencies:))
    let (serviceA, serviceB) = container.resolve(ServicesBuilder.self)!.makeServices()
    XCTAssertNotNil(serviceA.serviceB)
    XCTAssertNotNil(serviceB.serviceA)
    XCTAssertTrue(serviceA === serviceB.serviceA)
    XCTAssertTrue(serviceB === serviceA.serviceB)
  }

  func testExampleAssemblies() {
    struct Sample {}
    struct Sample2 {}
    struct Assembly: AKAssembly {
      func assemble(container: AKContainer) {
        container.singleton.autoregister(value: Sample())
      }
    }
    struct Assembly2: AKAssembly {
      func assemble(container: AKContainer) {
        container.singleton.autoregister(value: Sample2())
      }
    }
    let container = makeContainer()
    container.registerMany(assemblies: [
      Assembly(),
      Assembly2(),
    ])
    XCTAssertNotNil(container.resolve(Sample.self))
    XCTAssertNotNil(container.resolve(Sample2.self))
  }
}
