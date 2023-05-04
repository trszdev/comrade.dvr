import Swinject
import SwinjectExtensions
import Foundation

public enum ThumbnailAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container
      .register(AssetThumbnailing.self) { _ in
        AssetThumbnailer(queue: .init(label: "asset-thumbnailer-\(UUID().uuidString)" ))
      }
      .inObjectScope(.transient)
    container
      .register(ImageCache.self) { (resolver: Resolver, countLimit: Int) in
        AssetThumbnailCache(countLimit: countLimit, assetThumbnailing: resolver.resolve(AssetThumbnailing.self)!)
      }
      .inObjectScope(.transient)
    container
      .register(ObservableImageCache.self) { (resolver: Resolver, countLimit: Int) in
        let cache = resolver.resolve(ImageCache.self, argument: countLimit)!
        return ObservableImageCache(cache: cache)
      }
      .inObjectScope(.transient)
  }
}
