import SwiftUI
import Combine

public extension View {
  func previewContainer(_ imageCache: ObservableImageCache) -> some View {
    PreviewContainerView(content: self, imageCache: imageCache)
  }
}

private struct PreviewContainerView<Content: View>: View {
  @State private var visible = false
  var content: Content
  var imageCache: ObservableImageCache

  var body: some View {
    content
      .environment(\.observableImageCache, visible ? imageCache : imageCacheStub)
      .onAppear {
        visible = true
      }
      .onDisappear {
        visible = false
        Task { @MainActor in
          imageCache.purgeCache()
        }
      }
  }
}

private let imageCacheStub = ObservableImageCache()
