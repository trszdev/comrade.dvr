import SwiftUI
import Assets
import LocalizedUtils
import CommonUI

struct HistoryItemVerticalView: View {
  @Environment(\.language) var language
  var item = HistoryItem.mockAudio

  var body: some View {
    HStack {
      HistoryItemPreviewView(item: item)

      VStack(alignment: .leading) {
        Text(language.format(date: item.createdAt, timeStyle: .long, dateStyle: .none))
          .fontWeight(.bold)

        Text(verbatim: item.deviceName)

        Text("\(language.string(.size)): \(language.fileSize(item.size))")
          .font(.footnote)
          .fontWeight(.thin)
          .foregroundColor(.secondary)

        Text("\(language.string(.duration)): \(language.duration(item.duration))")
          .font(.footnote)
          .fontWeight(.thin)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .contentShape(Rectangle())
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity)
  }
}

#if DEBUG
struct HistoryItemViewPreviews: PreviewProvider {
  static var previews: some View {
    HistoryItemVerticalView().background(Color.gray)
  }
}
#endif
