import AVFoundation
import Device
import Util
import Foundation

public protocol AudioRecorder {
  func setup(configuration: MicrophoneConfiguration?, maxDuration: TimeInterval)
  func record()
  func stop()
}

final class AudioRecorderImpl: NSObject, AudioRecorder {
  private let urlMaker: () -> URL
  private var configuration: MicrophoneConfiguration?
  private var recorders = [URL: AVAudioRecorder]()
  private var maxDuration = TimeInterval.seconds(1)
  private let queue = DispatchQueue(label: "audio-recorder-\(UUID().uuidString)")

  init(urlMaker: @escaping () -> URL) {
    self.urlMaker = urlMaker
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(wasInterrupted(notification:)),
      name: AVAudioSession.interruptionNotification,
      object: nil
    )
  }

  func setup(configuration: MicrophoneConfiguration?, maxDuration: TimeInterval) {
    queue.sync { [weak self] in
      guard let self else { return }
      self.configuration = configuration
      self.maxDuration = maxDuration
    }
  }

  @objc private func wasInterrupted(notification: Notification) {
    guard let userInfo = notification.userInfo,
      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSession.InterruptionType(rawValue: typeValue)
    else {
      return
    }
    switch type {
    case .began:
      return interruptionWillBegin()
    case .ended:
      guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { break }
      let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
      return interruptionDidEnd(shouldResume: options.contains(.shouldResume))
    default:
      log.crit("Unknown notification")
    }
  }

  private func interruptionWillBegin() {
    queue.sync { [weak self] in
      self?.stopInternal()
    }
  }

  private func interruptionDidEnd(shouldResume: Bool) {
    record()
  }

  private func stopInternal() {
    for recorder in recorders.values {
      recorder.stop()
    }
  }

  private func makeRecorderAndStart() {
    guard let recorder = makeRecorder() else { return }
    recorder.delegate = self
    if recorder.record() {
      recorders[recorder.url] = recorder
    } else {
      log.crit("Failed to record audio \(recorder.url)")
    }
    let workItem = DispatchWorkItem { [weak self] in
      self?.stopInternal()
      self?.makeRecorderAndStart()
    }
    queue.asyncAfter(deadline: .now() + .milliseconds(maxDuration.milliseconds), execute: workItem)
    self.workItem = workItem
  }

  func stop() {
    queue.async { [weak self] in
      self?.stopInternal()
    }
  }

  func record() {
    queue.async { [weak self] in
      self?.makeRecorderAndStart()
    }
  }

  private var workItem: DispatchWorkItem?

  private func makeRecorder() -> AVAudioRecorder? {
    guard let configuration else { return nil }
    let url = urlMaker().appendingPathExtension("m4a")
    do {
      let recorder = try AVAudioRecorder(
        url: url,
        settings: configuration.quality.avAudioRecorderSettings
      )
      return recorder
    } catch {
      log.crit(error: error)
      log.crit("Failed to create recorder [\(url)]")
    }
    return nil
  }
}

extension AudioRecorderImpl: AVAudioRecorderDelegate {
  func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    if let error {
      log.crit(error: error)
    }
    log.crit()
  }

  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    if !flag {
      log.crit("Unsuccessfully finished recording [\(recorder.url)]")
    }
    queue.async { [weak self] in
      self?.recorders.removeValue(forKey: recorder.url)
    }
  }
}

private extension Quality {
  var avAudioRecorderSettings: [String: Any] {
    switch self {
    case .min:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
      ]
    case .low:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
      ]
    case .medium:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
      ]
    case .high:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
      ]
    case .max:
      return [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
      ]
    }
  }
}
