import SwiftUI
import CameraKit
import Combine

class SessionViewController: UIHostingController<AnyView> {
  struct Builder {
    let application: UIApplication
    let sessionViewBuilder: SessionViewBuilder
    let viewModel: SessionViewModelImpl

    func makeViewController(orientation: OrientationSetting, session: CKSession) -> SessionViewController {
      let rootView = sessionViewBuilder.makeView(viewModel: viewModel)
      viewModel.previews = Array(session.cameras.values).map { $0.previewView.eraseToAnyView() }
      let viewController = SessionViewController(
        application: application,
        orientation: uiOrientation(orientation),
        rootView: rootView
      )
      viewModel.sessionViewController = viewController
      return viewController
    }

    private func uiOrientation(_ orientation: OrientationSetting) -> UIInterfaceOrientationMask {
      switch orientation {
      case .portrait:
        return .portrait
      case .landscape:
        return .landscapeLeft
      case .system:
        switch UIDevice.current.orientation {
        case .landscapeLeft:
          return .landscapeLeft
        case .landscapeRight:
          return .landscapeRight
        case .portrait:
          return .portrait
        case .portraitUpsideDown:
          return .portraitUpsideDown
        default:
          return .portrait
        }
      }
    }
  }

  init(application: UIApplication, orientation: UIInterfaceOrientationMask, rootView: AnyView) {
    self.application = application
    self.orientation = orientation
    super.init(rootView: rootView)
    modalPresentationStyle = .fullScreen
  }

  @objc required dynamic init?(coder aDecoder: NSCoder) {
    notImplemented()
  }

  func present() -> Future<Void, Never> {
    Future { [application] promise in
      guard let topVc = application.windows.first?.topViewController else { return promise(.success) }
      topVc.present(self, animated: true) {
        promise(.success)
      }
    }
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    orientation
  }

  private let application: UIApplication
  private let orientation: UIInterfaceOrientationMask
}
