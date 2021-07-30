import SwiftUI
import CameraKit
import Combine

final class PreviewSessionViewModel: SessionViewModel {
  var previews = [AnyView]()

  func stopSession() {
    onStop()
  }

  @Published var microphoneEnabled = true
  var microphoneEnabledPublished: Published<Bool> { _microphoneEnabled }
  var microphoneEnabledPublisher: Published<Bool>.Publisher { $microphoneEnabled }

  @Published var microphoneMuted = false
  var microphoneMutedPublished: Published<Bool> { _microphoneMuted }
  var microphoneMutedPublisher: Published<Bool>.Publisher { $microphoneMuted }

  @Published var pressureLevel = CKPressureLevel.nominal
  var pressureLevelPublished: Published<CKPressureLevel> { _pressureLevel }
  var pressureLevelPublisher: Published<CKPressureLevel>.Publisher { $pressureLevel }

  @Published var infoText = "info text"
  var infoTextPublished: Published<String> { _infoText }
  var infoTextPublisher: Published<String>.Publisher { $infoText }

  func scheduleDismissAlertTimer() {
  }

  var dismissAlertPublisher: AnyPublisher<Void, Never> {
    PassthroughSubject<Void, Never>().eraseToAnyPublisher()
  }

  var errorPublisher: AnyPublisher<Error, Never> {
    PassthroughSubject<Error, Never>().eraseToAnyPublisher()
  }

  var onStop: () -> Void = {}
}
