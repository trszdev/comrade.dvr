import UIKit
import AVFoundation
import Combine
import CameraKit
import SwiftUI
import AVKit

final class MainViewController: UIViewController {
  private let responsivenessView: UISlider = {
    let result = UISlider()
    result.translatesAutoresizingMaskIntoConstraints = false
    result.addConstraint(result.widthAnchor.constraint(equalToConstant: 200))
    return result
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(responsivenessView)
    NSLayoutConstraint.activate([
      responsivenessView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      responsivenessView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
    DispatchQueue.main.asyncAfter(deadline: .now()) {
      CKAVManager.shared.sessionMakerPublisher
        .receive(on: DispatchQueue.main)
        .map { [weak self] sessionMaker in
          self?.startSession(sessionMaker: sessionMaker)
        }
        .sinkAndStore()
    }
  }

  private func addSessionTemplates(
    sessionMaker: CKSessionMaker,
    alertVc: UIAlertController,
    backCameraId: CKDeviceID?,
    frontCameraId: CKDeviceID?,
    microphoneId: CKDeviceID?
  ) {
    if let backCameraId = backCameraId {
      addAction(
        alertVc: alertVc,
        title: microphoneId == nil ? "Back only" : "Back + mic",
        sessionMaker: sessionMaker,
        cameraIds: [backCameraId],
        microphoneId: microphoneId
      )
    }
    if let frontCameraId = frontCameraId {
      addAction(
        alertVc: alertVc,
        title: microphoneId == nil ? "Front only" : "Front + mic",
        sessionMaker: sessionMaker,
        cameraIds: [frontCameraId],
        microphoneId: microphoneId
      )
    }
    if let backCameraId = backCameraId, let frontCameraId = frontCameraId {
      addAction(
        alertVc: alertVc,
        title: microphoneId == nil ? "Back + front" : "Back + front + mic",
        sessionMaker: sessionMaker,
        cameraIds: [backCameraId, frontCameraId],
        microphoneId: microphoneId
      )
    }
  }

  private func startSession(sessionMaker: CKSessionMaker) {
    let backCameraId = sessionMaker.adjustableConfiguration.camera(.back)?.id
    let frontCameraId = sessionMaker.adjustableConfiguration.camera(.front)?.id
    let microphoneId = sessionMaker.adjustableConfiguration.microphone?.id
    print("Available configuration:")
    dump(sessionMaker.adjustableConfiguration.ui)
    guard backCameraId != nil, frontCameraId != nil else {
      alert(message: "No default cameras found")
      return
    }
    let alertVc = UIAlertController(title: "Choose preset", message: nil, preferredStyle: .alert)
    addSessionTemplates(
      sessionMaker: sessionMaker,
      alertVc: alertVc,
      backCameraId: backCameraId,
      frontCameraId: frontCameraId,
      microphoneId: microphoneId
    )
    addSessionTemplates(
      sessionMaker: sessionMaker,
      alertVc: alertVc,
      backCameraId: backCameraId,
      frontCameraId: frontCameraId,
      microphoneId: nil
    )
    present(alertVc, animated: true, completion: nil)
  }

  private func addAction(
    alertVc: UIAlertController,
    title: String,
    sessionMaker: CKSessionMaker,
    cameraIds: [CKDeviceID],
    microphoneId: CKDeviceID?
  ) {
    let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
      guard let self = self else { return }
      do {
        let session = try self.makeSession(sessionMaker: sessionMaker, cameraIds: cameraIds, microphoneId: microphoneId)
        self.alert(title: "Session info", message: String(describing: session.configuration)) {
          let viewBuilder = Assembly().hashContainer.resolve(CameraKitViewBuilder.self)!
          let view = viewBuilder.makeView(session: session)
          let hostingVc = UIHostingControllerWithoutRotation(rootView: view)
          hostingVc.view.backgroundColor = .black
          hostingVc.modalPresentationStyle = .fullScreen
          self.present(hostingVc, animated: true, completion: nil)
        }
      } catch {
        self.alert(message: error.localizedDescription)
      }
    }
    alertVc.addAction(action)
  }

  private func alert(title: String = "Error", message: String, afterOk: (() -> Void)? = nil) {
    let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if let afterOk = afterOk {
      alertVc.addAction(UIAlertAction(title: "OK", style: .default) { _ in afterOk() })
    }
    present(alertVc, animated: true, completion: nil)
  }

  private func makeSession(
    sessionMaker: CKSessionMaker,
    cameraIds: [CKDeviceID],
    microphoneId: CKDeviceID?
  ) throws -> CKSession {
    let cameras = cameraIds.map { CKDevice(id: $0, configuration: sampleCameraConfiguration)}
    let microphone = microphoneId.flatMap { CKDevice(id: $0, configuration: sampleMicrophoneConfiguration) }
    let configuration = CKConfiguration(cameras: Set(cameras), microphone: microphone)
    return try sessionMaker.makeSession(configuration: configuration)
  }

  private var sampleCameraConfiguration: CKCameraConfiguration {
    let interfaceOrienation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    let orientation: CKOrientation
    switch interfaceOrienation! {
    case .landscapeLeft:
      orientation = .landscapeLeft
    case .landscapeRight:
      orientation = .landscapeRight
    case .portraitUpsideDown:
      orientation = .portraitUpsideDown
    default:
      orientation = .portrait
    }
    return CKCameraConfiguration(
      size: CKSize(width: 1920, height: 1080),
      zoom: 1,
      fps: 60,
      fieldOfView: 107,
      orientation: orientation,
      autoFocus: .phaseDetection,
      stabilizationMode: .auto,
      videoGravity: .resizeAspect,
      videoQuality: .medium
    )
  }

  private var sampleMicrophoneConfiguration = CKMicrophoneConfiguration(
    orientation: .portrait,
    location: .unspecified,
    polarPattern: .unspecified,
    duckOthers: false,
    useSpeaker: false,
    useBluetoothCompatibilityMode: false,
    audioQuality: .max
  )
}

class UIHostingControllerWithoutRotation<Content: View>: UIHostingController<Content> {
  override var shouldAutorotate: Bool {
    false
  }
}
