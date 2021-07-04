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
  func stop()
}

final class CameraKitViewModelImpl: CameraKitViewModel {
  init(session: CKSession, logger: Logger, shareViewPresenter: ShareViewPresenter) {
    self.session = session
    self.logger = logger
    self.shareViewPresenter = shareViewPresenter
    self.previews = Array(session.cameras.values.map { $0.previewView.eraseToAnyView() })
    self.pressureLevel = session.pressureLevel
  }

  weak var hostingVc: UIViewController?

  @Published var pressureLevel: CKPressureLevel
  var pressureLevelPublished: Published<CKPressureLevel> { _pressureLevel }
  var pressureLevelPublisher: Published<CKPressureLevel>.Publisher { $pressureLevel }
  var previews: [IdentifiableAnyView]

  func requestMediaChunk() {
    logger.log("request media chunk")
    session.requestMediaChunk()
  }

  func setupHandlers() {
    session.outputPublisher
      .map(sessionDidOutput(mediaChunk:))
      .mapError(sessionDidOutput(error:))
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
      .store(in: &cancellables)
    session.pressureLevelPublisher
      .receive(on: DispatchQueue.main)
      .map(sessionDidChangePressureLevel(pressureLevel:))
      .sink {}
      .store(in: &cancellables)
  }

  func stop() {
    hostingVc?.dismiss(animated: true, completion: nil)
    cancellables = Set()
  }

  private func sessionDidChangePressureLevel(pressureLevel: CKPressureLevel) {
    logger.log("Pressure level changed")
    self.pressureLevel = pressureLevel
  }

  private func sessionDidOutput(mediaChunk: CKMediaChunk) {
    logger.log("Received chunk from \(mediaChunk.deviceId.value)")
    let url2 = mediaChunk.url.appendingPathExtension(mediaChunk.fileType.rawValue)
    try? FileManager.default.moveItem(at: mediaChunk.url, to: url2)
    shareViewPresenter.presentFile(url: url2)
  }

  private func sessionDidOutput(error: Error) -> Error {
    logger.log("Received error: \(error.localizedDescription)")
    return error
  }

  private var cancellables = Set<AnyCancellable>()
  private let session: CKSession
  private let logger: Logger
  private let shareViewPresenter: ShareViewPresenter
}
