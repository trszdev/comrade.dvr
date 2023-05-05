import Assets
import SwiftUI

struct LoadingView: View {
  @Environment(\.appearance) var appearance

  var body: some View {
    ZStack {
      appearance.color(.mainBackgroundColor)

      appearance.image(.startIcon)
        .resizable()
        .frame(width: 100, height: 100)
    }
    .animation(.linear)
    .ignoresSafeArea()
  }
}

#if DEBUG
struct LoadingViewPreviews: PreviewProvider {
  static var previews: some View {
    LoadingView()
  }
}
#endif
