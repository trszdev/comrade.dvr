import CameraKit
import SwiftUI
import Combine
import AutocontainerKit

protocol CameraKitViewModel: ObservableObject {
  var previews: [IdentifiableAnyView] { get }
  var pressureLevel: CKPressureLevel { get }
  var pressureLevelPublished: Published<CKPressureLevel> { get }
  var pressureLevelPublisher: Published<CKPressureLevel>.Publisher { get }
  func requestMediaChunk()
}

final class CameraKitViewModelImpl: CameraKitViewModel {
  init(session: CKSession, logger: Logger, shareViewPresenter: ShareViewPresenter) {
    self.session = session
    self.logger = logger
    self.shareViewPresenter = shareViewPresenter
    self.previews = Array(session.cameras.values.map { $0.previewView.eraseToAnyView() })
    self.pressureLevel = session.pressureLevel
    session.delegate = self
  }

  @Published var pressureLevel: CKPressureLevel
  var pressureLevelPublished: Published<CKPressureLevel> { _pressureLevel }
  var pressureLevelPublisher: Published<CKPressureLevel>.Publisher { $pressureLevel }
  var previews: [IdentifiableAnyView]
  let session: CKSession
  let logger: Logger
  let shareViewPresenter: ShareViewPresenter

  func requestMediaChunk() {
    session.requestMediaChunk()
  }
}

extension CameraKitViewModelImpl: CKSessionDelegate {
  func sessionDidOutput(mediaChunk: CKMediaChunk) {
    logger.log(String(describing: mediaChunk))
    let url2 = mediaChunk.url.appendingPathExtension(mediaChunk.fileType.rawValue)
    try? FileManager.default.moveItem(at: mediaChunk.url, to: url2)
    shareViewPresenter.presentFile(url: url2)
  }

  func sessionDidOutput(error: Error) {
    logger.log("Received error: \(error.localizedDescription)")
  }
}
