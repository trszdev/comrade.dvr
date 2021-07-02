import SwiftUI
import CameraKit
import Combine

class SessionViewController: UIHostingController<AnyView> {
  struct Builder {
    let application: UIApplication
    let sessionViewBuilder: SessionViewBuilder
    let sessionViewModelBuilder: SessionViewModelBuilder

    func makeViewController(orientation: CKOrientation, session: CKSession) -> SessionViewController {
      let viewModel = sessionViewModelBuilder.makeViewModel(session: session)
      let rootView = sessionViewBuilder.makeView(viewModel: viewModel, orientation: orientation)
      let viewController = SessionViewController(
        application: application,
        orientation: orientation,
        rootView: rootView
      )
      viewModel.sessionViewController = viewController
      return viewController
    }
  }

  init(application: UIApplication, orientation: CKOrientation, rootView: AnyView) {
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

  override var preferredStatusBarStyle: UIStatusBarStyle {
    .lightContent
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    switch orientation {
    case .portrait:
      return .portrait
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    case .portraitUpsideDown:
      return .portraitUpsideDown
    }
  }

  private let application: UIApplication
  private let orientation: CKOrientation
}
