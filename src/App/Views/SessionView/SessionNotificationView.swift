import SwiftUI

struct SessionNotificationView: View {
  let text: String
  @Binding var isVisible: Bool

  var body: some View {
    Text(text)
      .foregroundColor(notificationTextColor)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
      .background(blurView)
      .offset(x: 0, y: 70)
      .onTapGesture {
        isVisible = false
      }
      .animation(nil)
      .opacity(isVisible ? 1 : 0)
      .defaultAnimation
  }

  private var blurView: VisualEffectView {
    VisualEffectView(effect: UIBlurEffect(style: .dark))
  }
}

private let notificationTextColor = Color(white: 0.8)
