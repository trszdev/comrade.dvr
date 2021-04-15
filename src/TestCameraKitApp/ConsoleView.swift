import SwiftUI

struct ConsoleView<Log: LogViewModel>: View {
  @ObservedObject var viewModel: Log

  var body: some View {
    MultilineTextView(text: viewModel.log)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.orange)
  }
}

private struct MultilineTextView: UIViewRepresentable {
  let text: String

  func makeUIView(context: Context) -> UITextView {
    let view = UITextView()
    view.isScrollEnabled = true
    view.isEditable = false
    view.isUserInteractionEnabled = true
    view.text = text
    view.backgroundColor = .clear
    view.textColor = .black
    return view
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
  }
}
