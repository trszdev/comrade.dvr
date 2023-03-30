import SwiftUI
import Combine

@MainActor
public protocol ImageCache {
  func image(for url: URL, size: CGSize) -> CGImage?
  func purgeCache()
  var cacheWillChangePublisher: AnyPublisher<Void, Never> { get }
}
