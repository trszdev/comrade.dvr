import Device
import Combine
import Util
import Foundation

public protocol CameraKitService: SessionConfigurator {
  func play()
  func stop()
  var monitorErrorPublisher: CurrentValuePublisher<SessionMonitorError?> { get }
}

public enum CameraKitServiceStub: CameraKitService {
  case shared

  public func play() {
  }

  public func stop() {
  }

  public var monitorErrorPublisher: CurrentValuePublisher<SessionMonitorError?> {
    CurrentValueSubject(nil).currentValuePublisher
  }

  public func configure(deviceConfiguration: DeviceConfiguration) throws {
  }
}

final class CameraKitServiceImpl: CameraKitService {
  init(
    sessionConfigurator: SessionConfigurator,
    monitor: SessionMonitor,
    store: SessionStore,
    frontCameraRecorder: VideoRecorder,
    backCameraRecorder: VideoRecorder,
    audioRecorder: AudioRecorder
  ) {
    self.sessionConfigurator = sessionConfigurator
    self.monitor = monitor
    self.store = store
    self.frontCameraRecorder = frontCameraRecorder
    self.backCameraRecorder = backCameraRecorder
    self.audioRecorder = audioRecorder
  }

  private let sessionConfigurator: SessionConfigurator
  private let monitor: SessionMonitor
  private weak var store: SessionStore?
  private var session: Session? { store?.session }
  private let frontCameraRecorder: VideoRecorder
  private let backCameraRecorder: VideoRecorder
  private let audioRecorder: AudioRecorder

  func play() {
    guard let session, !session.avSession.isRunning else { return }
    session.avSession.startRunning()
    monitor.checkAfterStart(session: session)
    guard monitorErrorPublisher.value == nil else { return }
    audioRecorder.record()
  }

  func stop() {
    guard let session, session.avSession.isRunning else { return }
    session.avSession.stopRunning()
    frontCameraRecorder.flush()
    backCameraRecorder.flush()
    audioRecorder.stop()
  }

  func configure(deviceConfiguration: DeviceConfiguration) throws {
    let wasRunning = session?.avSession.isRunning == true
    if wasRunning {
      stop()
    }
    recreateSession(deviceConfiguration: deviceConfiguration)
    if let session {
      try sessionConfigurator.configure(deviceConfiguration: deviceConfiguration)
      setupCameraRecorder(isFront: true, session: session, deviceConfiguration: deviceConfiguration)
      setupCameraRecorder(isFront: false, session: session, deviceConfiguration: deviceConfiguration)
      audioRecorder.setup(configuration: deviceConfiguration.microphone, maxDuration: deviceConfiguration.maxFileLength)
    }
    if wasRunning {
      play()
    }
  }

  private func setupCameraRecorder(isFront: Bool, session: Session, deviceConfiguration: DeviceConfiguration) {
    let cameraConfiguration = isFront ? deviceConfiguration.frontCamera : deviceConfiguration.backCamera
    guard let cameraConfiguration else { return }
    let recorder = isFront ? frontCameraRecorder : backCameraRecorder
    let framesToFlush = cameraConfiguration.framesToFlush(deviceConfiguration.maxFileLength)
    recorder.setup(output: session.frontOutput, framesToFlush: framesToFlush, configuration: cameraConfiguration)
  }

  private func recreateSession(deviceConfiguration: DeviceConfiguration) {
    guard let store else {
      log.crit("failed to recreate session")
      return
    }
    if deviceConfiguration.backCamera != nil, deviceConfiguration.frontCamera != nil {
      store.session = .init(multiCameraSession: .init())
    } else {
      store.session = .init(singleCameraSession: .init())
    }
  }

  var monitorErrorPublisher: CurrentValuePublisher<SessionMonitorError?> { monitor.errorPublisher }
}

private extension CameraConfiguration {
  func framesToFlush(_ time: TimeInterval) -> Int { Int(Double(fps) * time.seconds) }
}
