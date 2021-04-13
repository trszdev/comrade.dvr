import AVFoundation
import Combine

final class CKAVMicrophoneSession: CKSession {
  struct Builder {
    let mapper: CKAVConfigurationMapper
    let session: AVAudioSession
    let recorder: CKAVMicrophoneRecorder

    func makeSession(configuration: CKConfiguration) -> CKAVMicrophoneSession {
      CKAVMicrophoneSession(
        configuration: configuration,
        mapper: mapper,
        session: session,
        recorder: recorder
      )
    }
  }

  init(
    configuration: CKConfiguration,
    mapper: CKAVConfigurationMapper,
    session: AVAudioSession,
    recorder: CKAVMicrophoneRecorder
  ) {
    self.configuration = configuration
    self.mapper = mapper
    self.session = session
    self.recorder = recorder
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
  weak var delegate: CKSessionDelegate? {
    didSet {
      recorder.sessionDelegate = delegate
    }
  }

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
    try recorder.setup(microphoneId: microphone.id, audioQuality: microphone.configuration.audioQuality)
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
