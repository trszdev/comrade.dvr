import AVFoundation
import Util
import Device

public protocol VideoRecorder {
  func setup(output: AVCaptureVideoDataOutput, options: VideoRecorderOptions)
  func flush()
}

final class VideoRecorderImpl: NSObject, VideoRecorder {
  init(urlMaker: @escaping () -> URL) {
    self.urlMaker = urlMaker
    super.init()
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
  }

  func setup(output: AVCaptureVideoDataOutput, options: VideoRecorderOptions) {
    output.setSampleBufferDelegate(self, queue: self.queue)
    output.tryChangePixelFormat(quality: options.configuration.quality)
    queue.sync { [weak self] in
      self?.options = options
    }
  }

  func flush() {
    queue.async { [weak self] in
      self?.finalizeChunkIfNeeded(force: true)
    }
  }

  private let queue = DispatchQueue(label: "video-recorder-\(UUID().uuidString)")
  private var framesWritten = 0
  private var assetWriter: AVAssetWriter?
  private var options = VideoRecorderOptions(
    framesToFlush: 60 * 60 * 3,
    configuration: .defaultBackCamera,
    isLandscape: false
  )
  private var finishingWriters = [URL: AVAssetWriter]()
  private let urlMaker: () -> URL

  @objc private func interruptionWillBegin() {
    log.debug()
    queue.sync { [weak self] in
      self?.finalizeChunkIfNeeded(force: true)
    }
  }

  @objc private func interruptionDidEnd() {
    log.debug()
  }

  private func makeWriter() -> AVAssetWriter? {
    let url = urlMaker().appendingPathExtension("mov")
    do {
      let writer = try AVAssetWriter(url: url, fileType: .mov)
      writer.add(options.assetWriterInput)
      return writer
    } catch {
      log.warn("Error creating AVAssetWriter with url: \(url)")
      log.warn(error: error)
    }
    return nil
  }

  private func finalizeChunkIfNeeded(force: Bool = false) {
    guard let assetWriter, framesWritten >= options.framesToFlush || (force && framesWritten > 0) else { return }
    log.info("Finalizing chunk")
    framesWritten = 0
    let key = assetWriter.outputURL
    finishingWriters[key] = assetWriter
    self.assetWriter = nil
    assetWriter.finishWriting { [weak self, key] in
      self?.finishingWriters.removeValue(forKey: key)
    }
  }
}

extension VideoRecorderImpl: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    finalizeChunkIfNeeded()
    guard let assetWriter = self.assetWriter ?? makeWriter() else { return }
    self.assetWriter = assetWriter
    framesWritten += 1
    if assetWriter.status == .unknown {
      let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
      assetWriter.startWriting()
      assetWriter.startSession(atSourceTime: startTime)
      log.info("Starting write to \(assetWriter.outputURL)")
    }
    for input in assetWriter.inputs where input.isReadyForMoreMediaData {
      input.append(sampleBuffer)
    }
  }
}
