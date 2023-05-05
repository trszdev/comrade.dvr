import Device
import Combine
import Util
import Foundation
import AVFoundation

public protocol CameraKitService: SessionPlayer, SessionConfigurator, SessionMonitor {
}

public enum CameraKitServiceStub: CameraKitService {
  case shared

  public func play() async {
  }

  public func stop() {
  }

  public var monitorErrorPublisher: AnyPublisher<SessionMonitorError?, Never> {
    Empty().eraseToAnyPublisher()
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

  @MainActor private var avSession: AVCaptureSession? { session?.avSession }

  @MainActor func play() async {
    audioRecorder.record()
    guard let session, !session.avSession.isRunning else { return }
    await withTaskGroup(of: Void.self) { [weak self] _ in
      await self?.forcePlay(session: session)
    }
  }

  private func forcePlay(session: Session) async {
    await avSession?.startRunning()
    await checkAfterStart(session: session)
  }

  func stop() {
    audioRecorder.stop()
    guard let session, session.avSession.isRunning else { return }
    session.avSession.stopRunning()
    frontCameraRecorder.flush()
    backCameraRecorder.flush()
  }

  func configure(session: Session, deviceConfiguration: DeviceConfiguration) throws {
    self.session = session
//    let wasRunning = session.avSession.isRunning == true
//    if wasRunning {
//      stop()
//    }
    try sessionConfigurator.configure(session: session, deviceConfiguration: deviceConfiguration)
    setupCameraRecorder(isFront: true, session: session, deviceConfiguration: deviceConfiguration)
    setupCameraRecorder(isFront: false, session: session, deviceConfiguration: deviceConfiguration)
    audioRecorder.setup(configuration: deviceConfiguration.microphone, maxDuration: deviceConfiguration.maxFileLength)
//    if wasRunning {
//      play()
//    }
  }

  private func setupCameraRecorder(isFront: Bool, session: Session, deviceConfiguration: DeviceConfiguration) {
    let cameraConfiguration = isFront ? deviceConfiguration.frontCamera : deviceConfiguration.backCamera
    guard let cameraConfiguration else { return }
    let recorder = isFront ? frontCameraRecorder : backCameraRecorder
    let output = isFront ? session.frontOutput : session.backOutput
    recorder.setup(
      output: output,
      options: .init(
        framesToFlush: cameraConfiguration.framesToFlush(deviceConfiguration.maxFileLength),
        configuration: cameraConfiguration,
        isLandscape: deviceConfiguration.orientation.isLandscape
      )
    )
  }

  var monitorErrorPublisher: AnyPublisher<SessionMonitorError?, Never> { monitor.monitorErrorPublisher }

  @MainActor func checkAfterStart(session: Session) {
    monitor.checkAfterStart(session: session)
  }
}

private extension CameraConfiguration {
  func framesToFlush(_ time: TimeInterval) -> Int { Int(Double(fps) * time.seconds) }
}
