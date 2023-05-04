import SwiftUI

public final class CustomizableHostingController<Content: View>: UIHostingController<Content> {
  public override init(rootView: Content) {
    super.init(rootView: rootView)
    view.backgroundColor = .clear
  }

  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    forcedStatusBarStyle ?? super.preferredStatusBarStyle
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    switch forcedInterfaceOrientation {
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    case .portrait:
      return .portrait
    case .portraitUpsideDown:
      return .portraitUpsideDown
    default:
      return super.supportedInterfaceOrientations
    }
  }

  public var forcedInterfaceOrientation: UIInterfaceOrientation?
  public var forcedStatusBarStyle: UIStatusBarStyle?
}
