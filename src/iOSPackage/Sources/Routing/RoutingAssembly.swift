import Swinject
import SwinjectAutoregistration
import CommonUI
import SwiftUI
import ComposableArchitecture
import Settings
import SwinjectExtensions
import History
import Start
import DeviceState
import Paywall
import Util
import Assets
import Permissions

public enum RoutingAssembly: SharedAssembly {
  case shared

  public func assembleWithChildren(container: Container) -> [SharedAssembly] {
    container.assembleHosting()
    container.assembleShare()

    container.assembleRouting()
    container.assembleSession()
    container.assembleTabs()
    container.assembleLoading()

    container.assembleStart()
    container.assembleHistory()
    container.assembleSettings()

    container.assembleDevices()
    container.assemblePaywall()
    return [
      SettingsAssembly.shared,
      HistoryAssembly.shared,
      StartAssembly.shared,
      DeviceStateAssembly.shared,
      PaywallAssembly.shared,
      PermissionsAssembly.shared,
    ]
  }
}

private extension Container {
  func assembleSession() {
    registerWithView(SessionRouting.self, with: PaywallView.self) { viewController, _ in
      StubRouter(viewController: viewController)
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
        sessionRoutingFactory: .init(resolver.resolve(SessionRouting.self)!),
        paywallRoutingFactory: .init(resolver.resolve(PaywallRouting.self)!)
      )
    }
    .implements(Router.self)
  }

  func assembleHosting() {
    autoregister(HostingObject.self, initializer: HostingObject.init).inObjectScope(.container)
    autoregister(HostingControllerFactory.self, initializer: HostingControllerFactory.init)
  }

  func assembleDevices() {
    registerWithView(DeviceCameraRouting.self, with: DeviceCameraView.self) { viewController, resolver in
      DeviceRouter(
        navigationController: resolver.resolve(UINavigationController.self, name: .startNavigation)!,
        viewController: viewController
      )
    }
    registerWithView(DeviceMicrophoneRouting.self, with: DeviceMicrophoneView.self) { viewController, resolver in
      DeviceRouter(
        navigationController: resolver.resolve(UINavigationController.self, name: .startNavigation)!,
        viewController: viewController
      )
    }
  }

  func assembleStart() {
    registerWithView(StartRouting.self, with: StartView.self) { viewController, resolver in
      StartRouter(
        rootViewController: viewController,
        navigationController: resolver.resolve(UINavigationController.self, name: .startNavigation)!,
        deviceCameraRoutingFactory: .init(resolver.resolve(DeviceCameraRouting.self)!),
        deviceMicrophoneRoutingFactory: .init(resolver.resolve(DeviceMicrophoneRouting.self)!),
        permissionRoutingFactory: .init(resolver.resolve(PermissionRouting.self)!)
      )
    }
    .inObjectScope(.container)
    autoregister(PermissionRouter.self, initializer: PermissionRouter.init)
      .implements(PermissionRouting.self)
    .inObjectScope(.transient)
    registerSingleton(UINavigationController.self, name: .startNavigation) { _ in .init() }
  }

  func assembleTabs() {
    registerSingleton(TabRouting.self) { resolver in
      TabRouter(
        lazyStart: .init(resolver.resolve(StartRouting.self)!),
        lazyHistory: .init(resolver.resolve(HistoryRouting.self)!),
        lazySettings: .init(resolver.resolve(SettingsRouting.self)!),
        lazyTabBarViewController: .init(resolver.resolve(TabBarViewController.self)!)
      )
    }
    autoregister(TabBarViewController.self, initializer: TabBarViewController.init)
  }

  func assemblePaywall() {
    registerWithView(PaywallRouting.self, with: PaywallView.self) { viewController, _ in
      let customizableViewController = CustomizableHostingController(rootView: viewController.rootView)
      customizableViewController.forcedStatusBarStyle = .lightContent
      return StubRouter(viewController: customizableViewController)
    }
  }

  func assembleLoading() {
    register(LoadingView.self) { _ in LoadingView() }
    registerWithView(LoadingRouting.self, with: LoadingView.self) { viewController, _ in
      StubRouter(viewController: viewController)
    }
  }

  func assembleSettings() {
    registerSingleton(UINavigationController.self, name: .settingsNavigation) { _ in .init() }
    registerWithView(SettingsRouting.self, with: SettingsView.self) { viewController, resolver in
      let navigationController = resolver.resolve(UINavigationController.self, name: .settingsNavigation)!
      navigationController.viewControllers = [viewController]
      return SettingsRouter(viewController: navigationController)
    }
  }

  @discardableResult
  func registerWithView<Service, WithView: View>(
    _ serviceType: Service.Type,
    with viewType: WithView.Type,
    name: String? = nil,
    factory: @escaping (UIHostingController<HostingView<WithView>>, Resolver) -> Service
  ) -> ServiceEntry<Service> {
    register(serviceType, name: name) { resolver in
      let view = resolver.resolve(viewType)!
      let viewControllerFactory = resolver.resolve(HostingControllerFactory.self)!
      let viewController = viewControllerFactory.hostingController(rootView: view)
      return factory(viewController, resolver)
    }
  }
}

private extension String {
  static var startNavigation: Self { "StartNavigation" }
  static var settingsNavigation: Self { "SettingsNavigation" }
}
