import Foundation
import AVFoundation
import Combine

protocol CKAVMicrophoneRecorder: AnyObject {
  func requestMediaChunk()
  func setup(microphone: CKDevice<CKMicrophoneConfiguration>) throws
  func stop()
  func record()
}

final class CKAVMicrophoneRecorderImpl: NSObject, CKAVMicrophoneRecorder {
  struct Builder {
    let mediaChunkMaker: CKMediaChunkMaker

    func makeRecorder(sessionPublisher: CKSessionPublisher) -> CKAVMicrophoneRecorder {
      CKAVMicrophoneRecorderImpl(mediaChunkMaker: mediaChunkMaker, sessionPublisher: sessionPublisher)
    }
  }

  init(mediaChunkMaker: CKMediaChunkMaker, sessionPublisher: CKSessionPublisher) {
    self.mediaChunkMaker = mediaChunkMaker
    self.sessionPublisher = sessionPublisher
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
      sessionPublisher.outputPublisher.send(completion: .failure(error))
    }
  }

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

  private let sessionPublisher: CKSessionPublisher
  private var recorders = [URL: (AVAudioRecorder, CKMediaChunk)]()
  private let mediaChunkMaker: CKMediaChunkMaker
  private var microphone: CKDevice<CKMicrophoneConfiguration>?
}

extension CKAVMicrophoneRecorderImpl: AVAudioRecorderDelegate {
  func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    var newError = CKAVMicrophoneSessionError.unknownRecordingError
    if let error = error {
      newError = CKAVMicrophoneSessionError.recordingError(inner: error)
    }
    sessionPublisher.outputPublisher.send(completion: .failure(newError))
  }

  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    guard flag, let (_, mediaChunk) = recorders[recorder.url] else {
      sessionPublisher.outputPublisher.send(completion: .failure(CKAVMicrophoneSessionError.failedToFinish))
      return
    }
    recorders.removeValue(forKey: recorder.url)
    sessionPublisher.outputPublisher.send(mediaChunk)
  }
}
