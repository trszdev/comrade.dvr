import Foundation
import AVFoundation

protocol CKAVMicrophoneRecorder: AnyObject {
  func requestMediaChunk()
  func setup(microphone: CKDevice<CKMicrophoneConfiguration>) throws
  var sessionDelegate: CKSessionDelegate? { get set }
  func stop()
  func record()
}

final class CKAVMicrophoneRecorderImpl: NSObject, CKAVMicrophoneRecorder {
  init(mediaChunkMaker: CKMediaChunkMaker) {
    self.mediaChunkMaker = mediaChunkMaker
  }

  func requestMediaChunk() {
    stop()
    record()
  }

  func stop() {
    for (recorder, _) in recorders.values {
      recorder.stop()
    }
  }

  func record() {
    do {
      try recordInternal()
    } catch {
      sessionDelegate?.sessionDidOutput(error: error)
    }
  }

  weak var sessionDelegate: CKSessionDelegate?

  func setup(microphone: CKDevice<CKMicrophoneConfiguration>) throws {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(wasInterrupted(notification:)),
      name: AVAudioSession.interruptionNotification,
      object: nil
    )
    self.microphone = microphone
    try recordInternal()
  }

  private func recordInternal() throws {
    stop()
    do {
      guard let microphone = microphone else { return }
      let mediaChunk = mediaChunkMaker.makeMediaChunk(deviceId: microphone.id, fileType: .m4a)
      let recorder = try AVAudioRecorder(
        url: mediaChunk.url,
        settings: microphone.configuration.audioQuality.avAudioRecorderSettings
      )
      recorder.delegate = self
      if !recorder.record() {
        throw CKAVMicrophoneSessionError.invalidSettings
      }
      recorders[mediaChunk.url] = (recorder, mediaChunk)
    } catch {
      throw CKAVMicrophoneSessionError.cantConfigureSession(inner: error)
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
      break
    }
    assert(false, "Invalid notification")
  }

  private func interruptionWillBegin() {
    stop()
  }

  private func interruptionDidEnd(shouldResume: Bool) {
    record()
  }

  private var recorders = [URL: (AVAudioRecorder, CKMediaChunk)]()
  private let mediaChunkMaker: CKMediaChunkMaker
  private var microphone: CKDevice<CKMicrophoneConfiguration>?
}

extension CKAVMicrophoneRecorderImpl: AVAudioRecorderDelegate {
  func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    if let error = error {
      sessionDelegate?.sessionDidOutput(error: CKAVMicrophoneSessionError.recordingError(inner: error))
    } else {
      sessionDelegate?.sessionDidOutput(error: CKAVMicrophoneSessionError.unknownRecordingError)
    }
  }

  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    guard flag, let (_, mediaChunk) = recorders[recorder.url] else {
      sessionDelegate?.sessionDidOutput(error: CKAVMicrophoneSessionError.failedToFinish)
      return
    }
    recorders.removeValue(forKey: recorder.url)
    sessionDelegate?.sessionDidOutput(mediaChunk: mediaChunk)
  }
}
