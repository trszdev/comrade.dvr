import UIKit
import CameraKit
import SwiftUI
import Combine
import AVFoundation

final class CameraKitViewController: UIViewController {
  var session: CKSession!

  override func viewDidLoad() {
    super.viewDidLoad()
    CKAVManager.shared.sessionMakerPublisher
      .receive(on: DispatchQueue.global(qos: .userInteractive))
      .map { (sessionMaker: CKSessionMaker) -> CKSession in
        let adjustableBackCamera = sessionMaker.adjustableConfiguration.ui
          .cameras
          .first { $0.key.value == "back-camera" }!
          .value
        let cameraConfiguration = CKCameraConfiguration(
          size: CKSize(width: 1920, height: 1080),
          zoom: 1,
          fps: 30,
          fieldOfView: 80,
          orientation: .portrait,
          autoFocus: .phaseDetection,
          isVideoMirrored: false,
          stabilizationMode: .auto,
          videoGravity: .resizeAspect
        )
        let camera = CKDevice(id: adjustableBackCamera.id, configuration: cameraConfiguration)
        let conf = CKConfiguration(cameras: Set([camera]), microphone: nil)
        let neareast = sessionMaker.nearestConfigurationPicker.nearestConfiguration(for: conf)
        // let session = sessionMaker.makeSession(configuration: )
        return sessionMaker.makeSession(configuration: neareast)
      }
      .receive(on: DispatchQueue.main)
      .map { session in
        var session = session
        session.isRunning = true
        let previewVc = UIHostingController(rootView: session.cameras.first!.value.previewView)
        self.present(previewVc, animated: true, completion: nil)
      }
      .breakpointOnError()
      .sinkAndStore()
  }
}

private extension Publisher {
  func sinkAndStore() {
    // closure variables for debug purposes
    sink(receiveCompletion: { completion in
      switch completion {
      case let .failure(error):
        switch error {
        default:
          break
        }
      case .finished:
        break
      }
    }, receiveValue: { _ in
    }).storeUntilComplete()
  }
}

private extension AnyCancellable {
  func storeUntilComplete() {
    store(in: &cancellables)
  }
}

private var cancellables = Set<AnyCancellable>()
