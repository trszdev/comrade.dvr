import SwiftUI

struct HistoryCellViewModel: Identifiable {
  enum Preview {
    case cameraPreview
    case microphonePreview
    case preview(image: UIImage)
  }

  var id = UUID()
  var preview: Preview
  let date: Date
  let duration: TimeInterval
  let fileSize: FileSize
}

extension Default {
  static var historyCellViewModel: HistoryCellViewModel {
    HistoryCellViewModel(preview: .cameraPreview, date: Date(), duration: 1, fileSize: FileSize(bytes: 0))
  }
}
