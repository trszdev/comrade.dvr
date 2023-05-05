import SwiftUI
import ThumbnailKit
import Assets

struct HistoryItemPreviewView: View {
  var item = HistoryItem.mockAudio
  var size = CGFloat(70)
  var iconPaddingSize = CGFloat(5)
  private let previews: [ImageAsset] = [.preview1, .preview2, .preview3, .preview4, .preview5]

  var body: some View {
    if item.previewType == .video {
      previews.randomElement()?
        .image()
        .resizable()
        .scaledToFill()
        .frame(width: size, height: size)
        .clipped()
    } else if item.previewType == .selfie {
      ImageAsset.previewFront
        .image()
        .resizable()
        .scaledToFill()
        .frame(width: size, height: size)
        .clipped()
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
      Image(systemName: "mic.fill").resizable().scaledToFit()
    case .video, .selfie:
      Image(systemName: "video.square").resizable()
    }
  }
}
