import SwiftUI

extension Image {
  var fitResizable: some View {
    resizable().aspectRatio(contentMode: .fit)
  }
}
