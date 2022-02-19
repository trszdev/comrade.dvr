import Swinject

public extension Container {
  @discardableResult
  func registerInstance<Service>(_ service: Service, name: String? = nil) -> ServiceEntry<Service> {
    register(Service.self, name: name, factory: { _ in service })
  }

  @discardableResult
  func registerSingleton<Service>(
    _ serviceType: Service.Type,
    name: String? = nil,
    factory: @escaping (Resolver) -> Service
  ) -> ServiceEntry<Service> {
    register(Service.self, name: name, factory: factory).inObjectScope(.container)
  }
}
