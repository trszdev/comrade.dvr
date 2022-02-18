import Swinject
import SwinjectAutoregistration
import CommonUI
import SwiftUI

struct RoutingAssembly: Assembly {
  func assemble(container: Container) {
    container.register(Routing.self) { resolver in
      Router(
        tabRoutingFactory: .init(resolver.resolve(TabRouting.self)!),
        loadingRoutingFactory: .init(resolver.resolve(LoadingRouting.self)!),
        sessionRoutingFactory: .init(resolver.resolve(SessionRouting.self)!)
      )
    }
    container.register(SessionRouting.self) { _ in
      StubRouter(viewController: UIHostingController(rootView: Color.green))
    }
    container.register(SettingsRouting.self) { _ in
      StubRouter(viewController: UIHostingController(rootView: Color.yellow))
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
    container.register(MainRouting.self) { resolver in
      MainRouter(
        rootViewController: UIHostingController(rootView: Color.gray),
        navigationController: resolver.resolve(UINavigationController.self, name: .mainNavigation)!,
        deviceCameraRoutingFactory: .init(resolver.resolve(DeviceCameraRouting.self)!),
        deviceMicrophoneRoutingFactory: .init(resolver.resolve(DeviceMicrophoneRouting.self)!)
      )
    }
    container.register(TabRouting.self) { resolver in
      TabRouter(
        lazyMain: .init(resolver.resolve(MainRouting.self)!),
        lazyHistory: .init(resolver.resolve(HistoryRouting.self)!),
        lazySettings: .init(resolver.resolve(SettingsRouting.self)!)
      )
    }
    container
      .register(UINavigationController.self, name: .mainNavigation) { _ in .init() }
      .inObjectScope(.container)
  }
}

private extension String {
  static var mainNavigation: Self { "MainNavigation" }
}
