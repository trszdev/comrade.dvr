import Swinject
import SwinjectAutoregistration
import CommonUI
import SwiftUI
import ComposableArchitecture
import Settings
import SwinjectExtensions

public enum RoutingAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container.registerSingleton(Routing.self) { resolver in
      Router(
        tabRoutingFactory: .init(resolver.resolve(TabRouting.self)!),
        loadingRoutingFactory: .init(resolver.resolve(LoadingRouting.self)!),
        sessionRoutingFactory: .init(resolver.resolve(SessionRouting.self)!)
      )
    }
    container.register(SessionRouting.self) { _ in
      StubRouter(viewController: UIHostingController(rootView: Color.green))
    }
    container.register(HistoryRouting.self) { _ in
      StubRouter(viewController: UIHostingController(rootView: Color.pink))
    }
    container.register(LoadingRouting.self) { _ in
      StubRouter(viewController: UIHostingController(rootView: Color.white))
    }
    container.register(DeviceCameraRouting.self) { resolver in
      DeviceRouter(
        navigationController: resolver.resolve(UINavigationController.self, name: .mainNavigation)!,
        viewController: UIHostingController(rootView: Color.blue)
      )
    }
    container.register(DeviceMicrophoneRouting.self) { resolver in
      DeviceRouter(
        navigationController: resolver.resolve(UINavigationController.self, name: .mainNavigation)!,
        viewController: UIHostingController(rootView: Color.orange)
      )
    }
    container.registerSingleton(MainRouting.self) { resolver in
      MainRouter(
        rootViewController: UIHostingController(rootView: Color.gray),
        navigationController: resolver.resolve(UINavigationController.self, name: .mainNavigation)!,
        deviceCameraRoutingFactory: .init(resolver.resolve(DeviceCameraRouting.self)!),
        deviceMicrophoneRoutingFactory: .init(resolver.resolve(DeviceMicrophoneRouting.self)!)
      )
    }
    container.registerSingleton(TabRouting.self) { resolver in
      TabRouter(
        lazyMain: .init(resolver.resolve(MainRouting.self)!),
        lazyHistory: .init(resolver.resolve(HistoryRouting.self)!),
        lazySettings: .init(resolver.resolve(SettingsRouting.self)!),
        lazyTabBarViewController: .init(resolver.resolve(TabBarViewController.self)!)
      )
    }
    container.registerSingleton(UINavigationController.self, name: .mainNavigation) { _ in .init() }
    container
      .autoregister(HostingObject.self, initializer: HostingObject.init)
      .inObjectScope(.container)
    container.autoregister(HostingControllerFactory.self, initializer: HostingControllerFactory.init)
    assembleSettings(container: container)
  }

  private func assembleSettings(container: Container) {
    container.autoregister(SettingsView.self, initializer: SettingsView.init)
    container.register(SettingsRouting.self) { resolver in
      let view = resolver.resolve(SettingsView.self)!
      let factory = resolver.resolve(HostingControllerFactory.self)!
      let viewController = factory.hostingController(rootView: view)
      return StubRouter(viewController: viewController)
    }
  }
}

private extension String {
  static var mainNavigation: Self { "MainNavigation" }
}
