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
  private var recorder: AVAudioRecorder?
  private var isPlaying = false
  private var isInterrupted = false
  private var shouldRecordNextChunk: Bool { isPlaying && !isInterrupted }
  private var maxDuration = TimeInterval.seconds(1)

  init(urlMaker: @escaping () -> URL) {
    self.urlMaker = urlMaker
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(wasInterrupted(notification:)),
      name: AVAudioSession.interruptionNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(cameraInterruptionWillBegin),
      name: .AVCaptureSessionWasInterrupted,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(cameraInterruptionDidEnd),
      name: .AVCaptureSessionInterruptionEnded,
      object: nil
    )
  }

  func setup(configuration: MicrophoneConfiguration?, maxDuration: TimeInterval) {
    self.configuration = configuration
    self.maxDuration = maxDuration
  }

  @objc private func wasInterrupted(notification: Notification) {
    guard let userInfo = notification.userInfo,
      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSession.InterruptionType(rawValue: typeValue)
    else {
      log.crit("Unknown notification")
      return
    }
    switch type {
    case .began:
      log.debug("audio int begin")
      interruptionWillBegin()
    case .ended:
      log.debug("audio int end")
      interruptionDidEnd(shouldResume: false)
//      guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { break }
//      let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
//      return interruptionDidEnd(shouldResume: options.contains(.shouldResume))
    default:
      log.crit("Unknown notification")
    }
  }

  @objc private func cameraInterruptionWillBegin() {
    log.debug()
    interruptionWillBegin()
  }

  @objc private func cameraInterruptionDidEnd() {
    log.debug()
    interruptionDidEnd(shouldResume: false)
  }

  private func interruptionWillBegin() {
    isInterrupted = true
    stopInternal()
  }

  private func interruptionDidEnd(shouldResume: Bool) {
    isInterrupted = false
    recordInternal()
  }

  private func stopInternal() {
    self.recorder?.stop()
  }

  private func recordInternal() {
    guard isPlaying, !isInterrupted, recorder == nil else { return }
    guard let recorder = makeRecorder() else { return }
    recorder.delegate = self
    if recorder.record(forDuration: maxDuration) {
      log.info("Starting write to \(recorder.url)")
      self.recorder = recorder
    } else {
      log.crit("Failed to record audio \(recorder.url)")
    }
  }

  func stop() {
    isPlaying = false
    stopInternal()
  }

  func record() {
    isPlaying = true
    recordInternal()
  }

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
  }

  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    if flag {
      log.info("Finalizing chunk")
    } else {
      log.crit("Unsuccessfully finished recording [\(recorder.url)]")
    }
    self.recorder = nil
    guard isPlaying else { return }
    recordInternal()
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
