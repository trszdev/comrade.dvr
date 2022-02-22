import CoreGraphics
import CoreImage
import CommonUI
import Util
import Combine

@MainActor
final class AssetThumbnailCache: NSObject, ImageCache, NSCacheDelegate {
  nonisolated var cacheWillChangePublisher: AnyPublisher<Void, Never> {
    subject.eraseToAnyPublisher()
  }

  nonisolated init(cache: NSCache<NSString, CGImage> = .init(), assetThumbnailing: AssetThumbnailing) {
    self.cache = cache
    self.assetThumbnailing = assetThumbnailing
    super.init()
    cache.delegate = self
  }

  convenience nonisolated init(countLimit: Int, assetThumbnailing: AssetThumbnailing) {
    let cache = NSCache<NSString, CGImage>()
    cache.countLimit = countLimit
    self.init(cache: cache, assetThumbnailing: assetThumbnailing)
  }

  func purgeCache() {
    cache.removeAllObjects()
  }

  func image(for url: URL, size: CGSize) -> CGImage? {
    let key = NSString(string: url.absoluteString)
    if let cached = cache.object(forKey: key) {
      log.verbose("found cached: \(url)")
      return cached == empty ? nil : cached
    }
    log.verbose("not found cached: \(url)")
    Task {
      do {
        guard cache.object(forKey: key) == nil else { return }
        let thumb = try await assetThumbnailing.thumbnail(for: url, size: size)
        subject.send()
        cache.setObject(thumb, forKey: key)
      } catch {
        log.warn(error: error)
        cache.setObject(empty, forKey: key)
      }
    }
    return nil
  }

  func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
    subject.send()
  }

  private let subject = PassthroughSubject<Void, Never>()
  private var cache: NSCache<NSString, CGImage> = .init()
  private let assetThumbnailing: AssetThumbnailing
}

private let empty: CGImage = .transparentPixel()
