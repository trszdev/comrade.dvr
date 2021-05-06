import SwiftUI

struct HistoryView: View {
  var body: some View {
    Color.blue.ignoresSafeArea()
  }
}

#if DEBUG

struct HistoryViewPreview: PreviewProvider {
  static var previews: some View {
    HistoryView()
  }
}

#endif
