import Foundation
import AVFoundation

protocol CKAVMicrophoneRecorder: AnyObject {
  func requestMediaChunk()
  func setup(microphoneId: CKDeviceID, audioQuality: CKAudioQuality)
  var sessionDelegate: CKSessionDelegate? { get set }
  func stop()
  func record()
}

final class CKAVMicrophoneRecorderImpl: NSObject, CKAVMicrophoneRecorder {
  init(tempFileMaker: CKTempFileMaker, timestampMaker: CKTimestampMaker) {
    self.tempFileMaker = tempFileMaker
    self.timestampMaker = timestampMaker
  }

  func requestMediaChunk() {
    stop()
  }

  func stop() {
    for recorder in recorders.values {
      recorder.stop()
    }
  }

  func record() {
    stop()
    do {
      let recorder = try AVAudioRecorder(
        url: tempFileMaker.makeTempFile(),
        settings: audioQuality.avAudioRecorderSettings
      )
      recorder.delegate = self
      recorder.record()
      recorders[recorder.url] = recorder
    } catch {
      sessionDelegate?.sessionDidOutput(error: CKAVMicrophoneSessionError.cantConfigureSession(inner: error))
    }
  }

  weak var sessionDelegate: CKSessionDelegate?

  func setup(microphoneId: CKDeviceID, audioQuality: CKAudioQuality) {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(wasInterrupted(notification:)),
      name: AVAudioSession.interruptionNotification,
      object: nil
    )
    self.audioQuality = audioQuality
    self.microphoneId = microphoneId
    record()
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

  private var recorders = [URL: AVAudioRecorder]()
  private let tempFileMaker: CKTempFileMaker
  private let timestampMaker: CKTimestampMaker
  private var microphoneId = CKAVMicrophone.builtIn.value
  private var audioQuality = CKAudioQuality.medium
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
    recorders.removeValue(forKey: recorder.url)
    guard flag else {
      sessionDelegate?.sessionDidOutput(error: CKAVMicrophoneSessionError.failedToFinish)
      return
    }
    let mediaChunk = CKMediaChunk(
      timestamp: timestampMaker.currentTimestamp,
      url: recorder.url,
      deviceId: microphoneId,
      fileType: .m4a
    )
    sessionDelegate?.sessionDidOutput(mediaChunk: mediaChunk)
  }
}
