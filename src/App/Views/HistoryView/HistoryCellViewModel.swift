import SwiftUI

struct HistoryCellViewModel: Equatable {
  enum Preview: Equatable {
    case cameraPreview
    case microphonePreview
    case notAvailable
    case preview(image: UIImage)
  }

  var id: URL
  var preview: Preview
  let date: Date
  let duration: TimeInterval
  let fileSize: FileSize?
}

extension Default {
  static var historyCellViewModel: HistoryCellViewModel {
    HistoryCellViewModel(
      id: URL(string: "/dev/null")!,
      preview: .notAvailable,
      date: Date(),
      duration: 1,
      fileSize: FileSize(bytes: 0)
    )
  }
}
