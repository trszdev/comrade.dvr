import Foundation
import AVFoundation
import AutocontainerKit

protocol CKAVCameraRecorder: AVCaptureVideoDataOutputSampleBufferDelegate {
  func requestMediaChunk()
  func setup(
    output: AVCaptureVideoDataOutput,
    camera: CKDevice<CKCameraConfiguration>,
    sessionStartupInfo: CKSessionStartupInfo
  ) throws
}

protocol CKAVCameraRecorderBuilder {
  func makeRecorder(sessionPublisher: CKSessionPublisher) -> CKAVCameraRecorder
}

final class CKAVCameraRecorderBuilderImpl: AKBuilder, CKAVCameraRecorderBuilder {
  func makeRecorder(sessionPublisher: CKSessionPublisher) -> CKAVCameraRecorder {
    CKAVCameraRecorderImpl(
      mapper: resolve(CKAVConfigurationMapper.self),
      mediaUrlMaker: resolve(CKMediaURLMaker.self),
      sessionPublisher: sessionPublisher,
      timestampMakerBuilder: resolve(CKTimestampMakerBuilder.self)
    )
  }
}

final class CKAVCameraRecorderImpl: NSObject, CKAVCameraRecorder {
  init(
    mapper: CKAVConfigurationMapper,
    mediaUrlMaker: CKMediaURLMaker,
    sessionPublisher: CKSessionPublisher,
    timestampMakerBuilder: CKTimestampMakerBuilder
  ) {
    self.mapper = mapper
    self.mediaUrlMaker = mediaUrlMaker
    self.sessionPublisher = sessionPublisher
    self.timestampMakerBuilder = timestampMakerBuilder
    self.timestampMaker = timestampMakerBuilder.makeTimestampMaker()
  }

  func requestMediaChunk() {
    stop()
    tryStartRecording()
  }

  func setup(
    output: AVCaptureVideoDataOutput,
    camera: CKDevice<CKCameraConfiguration>,
    sessionStartupInfo: CKSessionStartupInfo
  ) throws {
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
    timestampMaker = timestampMakerBuilder.makeTimestampMaker()
    output.tryChangePixelFormat(quality: camera.configuration.videoQuality)
    self.camera = camera
    self.sessionStartupInfo = sessionStartupInfo
    try startRecording()
  }

  private let sessionPublisher: CKSessionPublisher

  private func makeMediaChunk(deviceId: CKDeviceID, fileType: CKFileType) -> CKMediaChunk {
    let startedAt = timestampMaker.currentTimestamp
    let mediaUrl = mediaUrlMaker
      .makeMediaURL(deviceId: deviceId, sessionStartupInfo: sessionStartupInfo, startedAt: startedAt)
      .appendingPathExtension(fileType.rawValue)
    let mediaChunk = CKMediaChunk(
      startedAt: startedAt,
      url: mediaUrl,
      deviceId: deviceId,
      fileType: fileType,
      finishedAt: startedAt
    )
    return mediaChunk
  }

  private func startRecording() throws {
    guard let camera = camera else { return }
    let mediaChunk = makeMediaChunk(deviceId: camera.id, fileType: .mov)
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
      let updatedMediaChunk = mediaChunk.with(finishedAt: self.timestampMaker.currentTimestamp)
      self.sessionPublisher.outputPublisher.send(updatedMediaChunk)
    }
  }

  @objc private func interruptionWillBegin() {
    stop()
  }

  @objc private func interruptionDidEnd() {
    tryStartRecording()
  }

  private var mediaChunk: CKMediaChunk?
  private var sessionStartupInfo = CKSessionStartupInfo()
  private var finishingWriters = [CKMediaChunk: AVAssetWriter]()
  private var videoWriter: AVAssetWriter?
  private var camera: CKDevice<CKCameraConfiguration>?
  private let mediaUrlMaker: CKMediaURLMaker
  private var timestampMaker: CKTimestampMaker
  private let timestampMakerBuilder: CKTimestampMakerBuilder
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
