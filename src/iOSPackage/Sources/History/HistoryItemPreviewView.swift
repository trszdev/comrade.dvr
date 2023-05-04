import SwiftUI
import ThumbnailKit

struct HistoryItemPreviewView: View {
  var item = HistoryItem.mockAudio
  var size = CGFloat(70)
  var iconPaddingSize = CGFloat(5)

  var body: some View {
    if item.previewType == .video {
      PreviewImage(url: item.url, size: .init(width: 2 * size, height: 2 * size)) { image in
        if let image = image {
          Image(decorative: image, scale: 1)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipped()
        } else {
          iconPreviewView
        }
      }
    } else {
      iconPreviewView
    }
  }

  private var iconPreviewView: some View {
    Color.secondary
      .reverseMask(
        iconView
          .padding(iconPaddingSize)
      )
      .frame(width: size, height: size)
  }

  @ViewBuilder private var iconView: some View {
    switch item.previewType {
    case .audio:
      Image(systemName: "mic.square").resizable()
    case .video:
      Image(systemName: "video.square").resizable()
    }
  }
}
