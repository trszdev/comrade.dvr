import SwiftUI
import CameraKit
import Combine

final class SessionViewController: UIHostingController<AnyView> {
  struct Builder {
    let application: UIApplication

    func makeViewController(orientation: CKOrientation, rootView: AnyView) -> SessionViewController {
      SessionViewController(
        application: application,
        orientation: orientation,
        rootView: rootView
      )
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
    Future { [weak self] promise in
      guard let self = self,
        let topVc = self.application.windows.first?.topViewController
      else {
        return promise(.success)
      }
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
