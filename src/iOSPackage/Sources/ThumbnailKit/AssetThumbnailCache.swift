import CoreGraphics
import CoreImage
import CommonUI
import Util
import Combine

@MainActor
final class AssetThumbnailCache: NSObject, ImageCache, NSCacheDelegate {
  var cacheWillChangePublisher: AnyPublisher<Void, Never> {
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
    subject.send()
    cache.removeAllObjects()
  }

  func image(for url: URL, size: CGSize) -> CGImage? {
    let entry = Entry(url: url, size: size)
    let key = entry.key
    if let cached = cache.object(forKey: key) {
      log.verbose("found cached: \(url)")
      return cached == empty ? nil : cached
    }
    guard !running.contains(entry) else { return nil }
    running.insert(entry)
    log.verbose("not found cached: \(url)")
    Task {
      do {
        let thumb = try await assetThumbnailing.thumbnail(for: url, size: size)
        subject.send()
        cache.setObject(thumb, forKey: key)
      } catch {
        log.warn(error: error)
        subject.send()
        cache.setObject(empty, forKey: key)
      }
      running.remove(entry)
    }
    return nil
  }

  nonisolated func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
    subject.send()
  }

  private let subject = PassthroughSubject<Void, Never>()
  private var cache: NSCache<NSString, CGImage> = .init()
  private let assetThumbnailing: AssetThumbnailing
  private var running = Set<Entry>()
}

private let empty: CGImage = .transparentPixel()

private struct Entry: Hashable, Codable {
  let url: URL
  let size: CGSize

  var key: NSString {
    do {
      let data = try JSONEncoder().encode(self)
      guard let string = String(data: data, encoding: .utf8) else { return .init() }
      return string as NSString
    } catch {
      log.warn(error: error)
    }
    return .init()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(size.height)
    hasher.combine(size.width)
    hasher.combine(url)
  }
}
