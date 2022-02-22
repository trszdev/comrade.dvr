import SwiftUI

extension EnvironmentValues {
  var observableImageCache: ObservableImageCache {
    get { self[ObservableImageCacheKey.self] }
    set { self[ObservableImageCacheKey.self] = newValue }
  }
}

private struct ObservableImageCacheKey: EnvironmentKey {
  static let defaultValue = ObservableImageCache(
    cache: AssetThumbnailCache(
      countLimit: 20,
      assetThumbnailing: AssetThumbnailer(queue: .init(label: "asset-thumbnailer-default"))
    )
  )
}
