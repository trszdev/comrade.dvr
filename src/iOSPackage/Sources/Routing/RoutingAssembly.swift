import Swinject
import SwinjectAutoregistration
import CommonUI
import SwiftUI
import ComposableArchitecture
import Settings
import SwinjectExtensions
import History

public enum RoutingAssembly: SharedAssembly {
  case shared

  public func assembleWithChildren(container: Container) -> [SharedAssembly] {
    container.assembleHosting()
    container.assembleShare()

    container.assembleRouting()
    container.assembleSession()
    container.assembleTabs()
    container.assembleLoading()

    container.assembleMain()
    container.assembleHistory()
    container.assembleSettings()

    container.assembleDevices()
    return [SettingsAssembly.shared, HistoryAssembly.shared]
  }
}

private extension Container {
  func assembleSession() {
    register(SessionRouting.self) { _ in
      StubRouter(viewController: UIHostingController(rootView: Color.green))
    }
  }

  func assembleShare() {
    register(ShareRouting.self) { resolver in
      let viewStore = resolver.resolve(ViewStore<HistoryState, HistoryAction>.self)!
      var activityItems = [Any]()
      if let url = viewStore.shareItem?.url {
        activityItems.append(url)
      }
      let viewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
      return StubRouter(viewController: viewController)
    }
  }

  func assembleHistory() {
    register(HistoryRouting.self) { resolver in
      let view = resolver.resolve(HistoryView.self)!
      let viewControllerFactory = resolver.resolve(HostingControllerFactory.self)!
      let viewController = viewControllerFactory.hostingController(rootView: view)

      return HistoryRouter(
        viewController: viewController,
        shareRoutingFactory: .init(resolver.resolve(ShareRouting.self)!)
      )
    }
  }

  func assembleRouting() {
    registerSingleton(Routing.self) { resolver in
      Router(
        tabRoutingFactory: .init(resolver.resolve(TabRouting.self)!),
        loadingRoutingFactory: .init(resolver.resolve(LoadingRouting.self)!),
        sessionRoutingFactory: .init(resolver.resolve(SessionRouting.self)!)
      )
    }
  }

  func assembleHosting() {
    autoregister(HostingObject.self, initializer: HostingObject.init).inObjectScope(.container)
    autoregister(HostingControllerFactory.self, initializer: HostingControllerFactory.init)
  }

  func assembleDevices() {
    register(DeviceCameraRouting.self) { resolver in
      DeviceRouter(
        navigationController: resolver.resolve(UINavigationController.self, name: .mainNavigation)!,
        viewController: UIHostingController(rootView: Color.blue)
      )
    }
    register(DeviceMicrophoneRouting.self) { resolver in
      DeviceRouter(
        navigationController: resolver.resolve(UINavigationController.self, name: .mainNavigation)!,
        viewController: UIHostingController(rootView: Color.orange)
      )
    }
  }

  func assembleMain() {
    registerSingleton(MainRouting.self) { resolver in
      MainRouter(
        rootViewController: UIHostingController(rootView: Color.gray),
        navigationController: resolver.resolve(UINavigationController.self, name: .mainNavigation)!,
        deviceCameraRoutingFactory: .init(resolver.resolve(DeviceCameraRouting.self)!),
        deviceMicrophoneRoutingFactory: .init(resolver.resolve(DeviceMicrophoneRouting.self)!)
      )
    }
    registerSingleton(UINavigationController.self, name: .mainNavigation) { _ in .init() }
  }

  func assembleTabs() {
    registerSingleton(TabRouting.self) { resolver in
      TabRouter(
        lazyMain: .init(resolver.resolve(MainRouting.self)!),
        lazyHistory: .init(resolver.resolve(HistoryRouting.self)!),
        lazySettings: .init(resolver.resolve(SettingsRouting.self)!),
        lazyTabBarViewController: .init(resolver.resolve(TabBarViewController.self)!)
      )
    }
    autoregister(TabBarViewController.self, initializer: TabBarViewController.init)
  }

  func assembleLoading() {
    register(LoadingView.self) { _ in LoadingView() }
    registerWithView(LoadingRouting.self, with: LoadingView.self, factory: StubRouter.init)
  }

  func assembleSettings() {
    registerWithView(SettingsRouting.self, with: SettingsView.self, factory: StubRouter.init)
  }

  @discardableResult
  func registerWithView<Service, WithView: View>(
    _ serviceType: Service.Type,
    with viewType: WithView.Type,
    name: String? = nil,
    factory: @escaping (UIHostingController<HostingView<WithView>>) -> Service
  ) -> ServiceEntry<Service> {
    register(serviceType, name: name) { resolver in
      let view = resolver.resolve(viewType)!
      let viewControllerFactory = resolver.resolve(HostingControllerFactory.self)!
      let viewController = viewControllerFactory.hostingController(rootView: view)
      return factory(viewController)
    }
  }
}

private extension String {
  static var mainNavigation: Self { "MainNavigation" }
}
