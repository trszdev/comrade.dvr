import AVFoundation
import Combine
import AutocontainerKit

final class CKAVMicrophoneSession: CKSession, CKSessionPublisherProvider {
  struct Builder {
    let mapper: CKAVConfigurationMapper
    let session: AVAudioSession
    let locator: AKLocator

    func makeSession(configuration: CKConfiguration, sessionPublisher: CKSessionPublisher) -> CKAVMicrophoneSession {
      CKAVMicrophoneSession(
        configuration: configuration,
        mapper: mapper,
        session: session,
        recorder: locator
          .resolve(CKAVMicrophoneRecorderImpl.Builder.self)
          .makeRecorder(sessionPublisher: sessionPublisher),
        sessionPublisher: sessionPublisher
      )
    }
  }

  init(
    configuration: CKConfiguration,
    mapper: CKAVConfigurationMapper,
    session: AVAudioSession,
    recorder: CKAVMicrophoneRecorder,
    sessionPublisher: CKSessionPublisher
  ) {
    self.configuration = configuration
    self.mapper = mapper
    self.session = session
    self.recorder = recorder
    self.sessionPublisher = sessionPublisher
  }

  func requestMediaChunk() {
    recorder.requestMediaChunk()
  }

  let startupInfo = CKSessionStartupInfo()
  var cameras: [CKDeviceID: CKCameraDevice] { [:] }
  private(set) var microphone: CKMicrophoneDevice?
  let configuration: CKConfiguration
  let mapper: CKAVConfigurationMapper
  let session: AVAudioSession
  var pressureLevel: CKPressureLevel { .nominal }
  let sessionPublisher: CKSessionPublisher

  func start() throws {
    guard let microphone = configuration.microphone else { return }
    try configureMicrophone(configuration: microphone.configuration)
    if let input = mapper.audioInput(microphone.key), let dataSource = mapper.audioDataSource(microphone.key) {
      try session.setPreferredInput(input)
      try input.setPreferredDataSource(dataSource)
      if let polarPattern = microphone.configuration.polarPattern.avPolarPattern {
        try dataSource.setPreferredPolarPattern(polarPattern)
      }
    }
    try recorder.setup(microphone: microphone)
    self.microphone = CKAVMicrophoneDevice(device: microphone) { [weak self] isMuted in
      if isMuted {
        self?.recorder.stop()
      } else {
        self?.recorder.record()
      }
    }
  }

  private func configureMicrophone(configuration: CKMicrophoneConfiguration) throws {
    var options = AVAudioSession.CategoryOptions()
    options.update(with: configuration.duckOthers ? .duckOthers : .mixWithOthers)
    if configuration.useSpeaker {
      options.update(with: .defaultToSpeaker)
    } else {
      options.update(with: [.allowAirPlay, .allowBluetoothA2DP])
      if configuration.useBluetoothCompatibilityMode {
        options.update(with: .allowBluetooth)
      }
    }
    do {
      try session.setPreferredInputOrientation(configuration.orientation.avStereoOrientation)
    } catch {
      throw CKAVMicrophoneSessionError.cantSetInputOrientation(inner: error)
    }
    do {
      try session.setCategory(.playAndRecord, mode: .default, options: options)
      try session.setActive(true)
    } catch {
      throw CKAVMicrophoneSessionError.cantConfigureSession(inner: error)
    }
  }

  private let recorder: CKAVMicrophoneRecorder
}

private final class CKAVMicrophoneDevice: CKMicrophoneDevice {
  init(device: CKDevice<CKMicrophoneConfiguration>, didChangeMuted: @escaping (Bool) -> Void) {
    self.device = device
    self.didChangeMuted = didChangeMuted
  }

  let device: CKDevice<CKMicrophoneConfiguration>
  let didChangeMuted: (Bool) -> Void
  var isMuted: Bool = false {
    didSet {
      didChangeMuted(isMuted)
    }
  }
}
