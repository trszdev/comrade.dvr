import SwiftUI

final class CustomizableHostingController<Content: View>: UIHostingController<Content> {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    forcedStatusBarStyle ?? super.preferredStatusBarStyle
  }

  var forcedStatusBarStyle: UIStatusBarStyle?
}
