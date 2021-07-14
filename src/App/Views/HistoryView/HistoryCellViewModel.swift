import SwiftUI

struct HistoryCellViewModel: Identifiable {
  enum Preview {
    case cameraPreview
    case microphonePreview
    case preview(image: UIImage)
  }

  var id: URL
  var preview: Preview
  let date: Date
  let duration: TimeInterval
  let fileSize: FileSize
}

extension Default {
  static var historyCellViewModel: HistoryCellViewModel {
    HistoryCellViewModel(
      id: URL(string: "/dev/null")!,
      preview: .cameraPreview,
      date: Date(),
      duration: 1,
      fileSize: FileSize(bytes: 0)
    )
  }
}
