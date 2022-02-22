import AVFoundation
import UIKit
import Util

final class AssetThumbnailer: AssetThumbnailing {
  init(queue: DispatchQueue) {
    self.queue = queue
  }

  func thumbnail(for url: URL, size: CGSize) async throws -> CGImage {
    try await withCheckedThrowingContinuation { continuation in
      queue.async {
        let asset = AVAsset(url: url)
        let time = CMTimeMake(value: asset.duration.value / 2, timescale: asset.duration.timescale)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = size
        do {
          let thumbnailImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
          continuation.resume(returning: thumbnailImage)
        } catch {
          log.warn(error: error)
          continuation.resume(throwing: error)
        }
      }
    }
  }

  private let queue: DispatchQueue
}
