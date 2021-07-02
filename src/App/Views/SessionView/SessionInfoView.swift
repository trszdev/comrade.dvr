import SwiftUI

struct SessionInfoView: View {
  let text: String
  @Binding var isVisible: Bool

  var body: some View {
    ZStack(alignment: .topTrailing) {
      blurView
      InfoTextView(text: text)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .animation(nil)
      Image(sfSymbol: .cross)
        .fitResizable
        .padding()
        .frame(width: 50, height: 50)
        .background(Color.clear.contentShape(Rectangle()))
        .foregroundColor(.white)
        .onTapGesture {
          isVisible = false
        }
    }
    .padding()
    .opacity(isVisible ? 1 : 0)
    .defaultAnimation
  }

  private var blurView: VisualEffectView {
    VisualEffectView(effect: UIBlurEffect(style: .dark))
  }
}

private let notificationTextColor = Color(white: 0.8)

private struct InfoTextView: UIViewRepresentable {
  let text: String

  func makeUIView(context: Context) -> UITextView {
    let view = UITextView()
    view.isScrollEnabled = true
    view.scrollsToTop = true
    view.isEditable = false
    view.isUserInteractionEnabled = true
    view.text = text
    view.backgroundColor = .clear
    view.textColor = UIColor(notificationTextColor)
    view.font = .preferredFont(forTextStyle: .title3)
    return view
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
  }
}
