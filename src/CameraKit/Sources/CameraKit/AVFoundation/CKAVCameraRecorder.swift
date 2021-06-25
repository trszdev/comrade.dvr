import Foundation
import AVFoundation
import AutocontainerKit

protocol CKAVCameraRecorder: AVCaptureVideoDataOutputSampleBufferDelegate {
  func requestMediaChunk()
  func setup(output: AVCaptureVideoDataOutput, camera: CKDevice<CKCameraConfiguration>) throws
}

protocol CKAVCameraRecorderBuilder {
  func makeRecorder(sessionPublisher: CKSessionPublisher) -> CKAVCameraRecorder
}

struct CKAVCameraRecorderBuilderImpl: CKAVCameraRecorderBuilder {
  let mapper: CKAVConfigurationMapper
  let mediaChunkMaker: CKMediaChunkMaker

  func makeRecorder(sessionPublisher: CKSessionPublisher) -> CKAVCameraRecorder {
    CKAVCameraRecorderImpl(mapper: mapper, mediaChunkMaker: mediaChunkMaker, sessionPublisher: sessionPublisher)
  }
}

final class CKAVCameraRecorderImpl: NSObject, CKAVCameraRecorder {
  init(mapper: CKAVConfigurationMapper, mediaChunkMaker: CKMediaChunkMaker, sessionPublisher: CKSessionPublisher) {
    self.mapper = mapper
    self.mediaChunkMaker = mediaChunkMaker
    self.sessionPublisher = sessionPublisher
  }

  func requestMediaChunk() {
    stop()
    tryStartRecording()
  }

  func setup(output: AVCaptureVideoDataOutput, camera: CKDevice<CKCameraConfiguration>) throws {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(interruptionWillBegin),
      name: .AVCaptureSessionWasInterrupted,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(interruptionDidEnd),
      name: .AVCaptureSessionInterruptionEnded,
      object: nil
    )
    output.tryChangePixelFormat(quality: camera.configuration.videoQuality)
    self.camera = camera
    try startRecording()
  }

  private let sessionPublisher: CKSessionPublisher

  private func startRecording() throws {
    guard let camera = camera else { return }
    let mediaChunk = mediaChunkMaker.makeMediaChunk(deviceId: camera.id, fileType: .mov)
    do {
      let videoWriter = try AVAssetWriter(outputURL: mediaChunk.url, fileType: .mov)
      let videoWriterInput = camera.configuration.assetWriterInput
      videoWriter.add(videoWriterInput)
      self.videoWriter = videoWriter
    } catch {
      throw CKAVCameraSessionError.cantConfigureDevice(inner: error)
    }
    self.mediaChunk = mediaChunk
  }

  private func tryStartRecording() {
    do {
      try startRecording()
    } catch {
      sessionPublisher.outputPublisher.send(completion: .failure(error))
    }
  }

  private func stop() {
    guard let mediaChunk = mediaChunk, let videoWriter = videoWriter, videoWriter.status != .unknown else { return }
    self.mediaChunk = nil
    self.videoWriter = nil
    finishingWriters[mediaChunk] = videoWriter
    videoWriter.finishWriting { [weak self] in
      guard let self = self else { return }
      self.finishingWriters.removeValue(forKey: mediaChunk)
      self.sessionPublisher.outputPublisher.send(mediaChunk)
    }
  }

  @objc private func interruptionWillBegin() {
    stop()
  }

  @objc private func interruptionDidEnd() {
    tryStartRecording()
  }

  private var mediaChunk: CKMediaChunk?
  private var finishingWriters = [CKMediaChunk: AVAssetWriter]()
  private var videoWriter: AVAssetWriter?
  private var camera: CKDevice<CKCameraConfiguration>?
  private let mediaChunkMaker: CKMediaChunkMaker
  private let mapper: CKAVConfigurationMapper
}

extension CKAVCameraRecorderImpl: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let videoWriter = videoWriter,
      let input = connection.inputPorts.first?.input,
      let deviceInput = input as? AVCaptureDeviceInput,
      let id = mapper.id(deviceInput.device),
      id.deviceId == camera?.id
    else {
      return
    }
    if videoWriter.status == .unknown {
      let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
      videoWriter.startWriting()
      videoWriter.startSession(atSourceTime: startTime)
    }
    for input in videoWriter.inputs where input.isReadyForMoreMediaData {
      input.append(sampleBuffer)
    }
  }
}