import SwiftUI
import Combine
import Util

@MainActor
public final class ObservableImageCache: ObservableObject, ImageCache {
  public var cacheWillChangePublisher: AnyPublisher<Void, Never> {
    objectWillChange.eraseToAnyPublisher()
  }

  public nonisolated init(cache: ImageCache? = nil) {
    self.cache = cache
    Task { @MainActor [weak self] in
      self?.cancellable = cache?.cacheWillChangePublisher.sink { [weak self] _ in
        self?.objectWillChange.send()
        log.verbose("objectWillChange")
      }
    }
  }

  public func image(for url: URL, size: CGSize) -> CGImage? {
    cache?.image(for: url, size: size)
  }

  public func purgeCache() {
    cache?.purgeCache()
  }

  private var cancellable: AnyCancellable!
  private let cache: ImageCache?
}
