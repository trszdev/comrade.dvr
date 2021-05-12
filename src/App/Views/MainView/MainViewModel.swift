import SwiftUI

protocol MainViewModel {
  var startView: AnyView { get }
  var historyView: AnyView { get }
  var settingsView: AnyView { get }
  var navigationViewController: UINavigationController { get }
}

#if DEBUG

struct PreviewMainViewModel: MainViewModel {
  let navigationViewController: UINavigationController = CustomNavigationController()

  var startView: AnyView {
    let startViewModel = PreviewStartViewModel(
      presentAddNewDeviceScreenStub: {
        navigationViewController.presentView {
          Color.red.ignoresSafeArea()
        }
      },
      presentConfigureDeviceScreenStub: { device in
        navigationViewController.presentView {
          ZStack {
            Color.purple.ignoresSafeArea()
            Text(device.name)
          }
        }
      })
    let startView = StartView(viewModel: startViewModel)
    return AnyView(startView)
  }

  var historyView: AnyView {
    AnyView(Color.blue.ignoresSafeArea())
  }

  var settingsView: AnyView {
    AnyView(SettingsView())
  }
}

private final class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
  init() {
    super.init(navigationBarClass: nil, toolbarClass: nil)
    delegate = self
    isNavigationBarHidden = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tryHideNavigationBar()
  }

  func navigationController(
    _ navigationController: UINavigationController,
    willShow viewController: UIViewController,
    animated: Bool
  ) {
    tryHideNavigationBar()
  }

  private func tryHideNavigationBar() {
    guard viewControllers.count < 2 else { return }
    setNavigationBarHidden(true, animated: false)
  }
}

#endif
