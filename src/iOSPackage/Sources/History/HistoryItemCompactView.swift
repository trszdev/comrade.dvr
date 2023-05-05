import SwiftUI
import Assets
import LocalizedUtils
import CommonUI

struct HistoryItemCompactView: View {
  @Environment(\.language) var language
  var item = HistoryItem.mockAudio

  var body: some View {
    HistoryItemPreviewView(item: item, size: 170, iconPaddingSize: 12)
      .overlay(
        VStack(alignment: .leading) {
          Spacer()

          HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
              Text(language.format(date: item.createdAt, timeStyle: .medium, dateStyle: .none))
                .fontWeight(.bold)

              Text(verbatim: item.deviceName)
                .fontWeight(.bold)
            }
            .padding(4)
            .background(Color.black)
            .foregroundColor(Color.accentColor)

            Spacer()
          }
        }
      )
  }
}

#if DEBUG
struct HistoryItemCompactViewPreviews: PreviewProvider {
  static var previews: some View {
    HistoryItemCompactView().background(Color.gray)
  }
}
#endif
