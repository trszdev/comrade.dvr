import AVFoundation
import Device
import Util

struct SessionMicrophoneConfigurator {
  let audioSession: AVAudioSession = .sharedInstance()
  let discovery = Discovery()

  func configureAndGetError(configuration: MicrophoneConfiguration?) -> SessionConfiguratorMicrophoneError? {
    do {
      try configure(configuration: configuration)
    } catch let error as SessionConfiguratorMicrophoneError {
      return error
    } catch {
    }
    return nil
  }

  func configure(configuration: MicrophoneConfiguration?) throws {
    guard let configuration else {
      do {
        try audioSession.setActive(false)
      } catch {
        log.crit(error: error)
        log.crit("Error disabling microphone")
        throw SessionConfiguratorMicrophoneError.runtimeError
      }
      return
    }
    var options = AVAudioSession.CategoryOptions()
    options.update(with: [.mixWithOthers, .allowAirPlay, .allowBluetoothA2DP])
//    options.update(with: configuration.duckOthers ? .duckOthers : .mixWithOthers)
//    if configuration.useSpeaker {
//      options.update(with: .defaultToSpeaker)
//    } else {
//      options.update(with: [.allowAirPlay, .allowBluetoothA2DP])
//      if configuration.useBluetoothCompatibilityMode {
//        options.update(with: .allowBluetooth)
//      }
//    }
//    do {
//      // try audioSession.setPreferredInputOrientation(configuration.orientation.avStereoOrientation)
//    } catch {
//      throw CKAVMicrophoneSessionError.cantSetInputOrientation(inner: error)
//    }
    do {
      try audioSession.setCategory(.playAndRecord, mode: .default, options: options)
      try audioSession.setActive(true)
    } catch {
      log.crit(error: error)
      log.crit("Error configuring microphone")
      throw SessionConfiguratorMicrophoneError.runtimeError
    }
    try updateInputDataSource(configuration: configuration)
  }

  private func updateInputDataSource(configuration: MicrophoneConfiguration?) throws {
    guard let audioInput = discovery.builtInMic else {
      log.warn("Built in microphone not found")
      return
    }
    do {
      try audioSession.setPreferredInput(audioInput)
    } catch {
      log.crit(error: error)
      log.crit("Failed to set audio input")
      throw SessionConfiguratorMicrophoneError.runtimeError
    }
    guard let avPolarPattern = configuration?.polarPattern.avPolarPattern else { return }
    let dataSource = audioInput.dataSources?.first { dataSource in
      dataSource.supportedPolarPatterns?.contains(avPolarPattern) ?? false
    }
    guard let dataSource else {
      log.warn("No datasource found for polar pattern \(avPolarPattern)")
      return
    }
    do {
      try audioInput.setPreferredDataSource(dataSource)
    } catch {
      log.crit(error: error)
      log.crit("Failed to set audio datasource")
      throw SessionConfiguratorMicrophoneError.runtimeError
    }
  }
}

private extension PolarPattern {
  var avPolarPattern: AVAudioSession.PolarPattern? {
    switch self {
    case .stereo:
      return .stereo
    case .subcardioid:
      return .subcardioid
    case .default:
      return nil
    case .omnidirectional:
      return .omnidirectional
    case .cardioid:
      return .cardioid
    }
  }
}
