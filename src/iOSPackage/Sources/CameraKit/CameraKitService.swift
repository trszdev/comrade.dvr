import Device
import Combine
import Util
import Foundation

public protocol CameraKitService: SessionConfigurator, SessionMonitor {
  func play()
  func stop()
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

  public func checkAfterStart(session: Session) {
  }

  public func configure(session: Session, deviceConfiguration: DeviceConfiguration) throws {
  }
}

final class CameraKitServiceImpl: CameraKitService {
  init(
    sessionConfigurator: SessionConfigurator,
    monitor: SessionMonitor,
    frontCameraRecorder: VideoRecorder,
    backCameraRecorder: VideoRecorder,
    audioRecorder: AudioRecorder
  ) {
    self.sessionConfigurator = sessionConfigurator
    self.monitor = monitor
    self.frontCameraRecorder = frontCameraRecorder
    self.backCameraRecorder = backCameraRecorder
    self.audioRecorder = audioRecorder
  }

  private let sessionConfigurator: SessionConfigurator
  private let monitor: SessionMonitor
  private weak var session: Session?
  private let frontCameraRecorder: VideoRecorder
  private let backCameraRecorder: VideoRecorder
  private let audioRecorder: AudioRecorder

  func play() {
    guard let session, !session.avSession.isRunning else { return }
    session.avSession.startRunning()
    monitor.checkAfterStart(session: session)
    guard monitor.monitorErrorPublisher.value == nil else { return }
    audioRecorder.record()
  }

  func stop() {
    guard let session, session.avSession.isRunning else { return }
    session.avSession.stopRunning()
    frontCameraRecorder.flush()
    backCameraRecorder.flush()
    audioRecorder.stop()
  }

  func configure(session: Session, deviceConfiguration: DeviceConfiguration) throws {
    self.session = session
    let wasRunning = session.avSession.isRunning == true
    if wasRunning {
      stop()
    }
    try sessionConfigurator.configure(session: session, deviceConfiguration: deviceConfiguration)
    setupCameraRecorder(isFront: true, session: session, deviceConfiguration: deviceConfiguration)
    setupCameraRecorder(isFront: false, session: session, deviceConfiguration: deviceConfiguration)
    audioRecorder.setup(configuration: deviceConfiguration.microphone, maxDuration: deviceConfiguration.maxFileLength)
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

  var monitorErrorPublisher: CurrentValuePublisher<SessionMonitorError?> { monitor.monitorErrorPublisher }

  func checkAfterStart(session: Session) {
    monitor.checkAfterStart(session: session)
  }
}

private extension CameraConfiguration {
  func framesToFlush(_ time: TimeInterval) -> Int { Int(Double(fps) * time.seconds) }
}
