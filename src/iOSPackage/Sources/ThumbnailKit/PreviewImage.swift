import SwiftUI

public struct PreviewImage<Content: View>: View {
  @Environment(\.observableImageCache) var observableImageCache

  public init(url: URL, size: CGSize, @ViewBuilder content: @escaping (CGImage?) -> Content) {
    self.url = url
    self.size = size
    self.content = content
  }

  public var body: some View {
    PreviewImageContainerView(url: url, size: size, content: content)
      .environmentObject(observableImageCache)
  }

  private let url: URL
  private let size: CGSize
  @ViewBuilder private let content: (CGImage?) -> Content
}

private struct PreviewImageContainerView<Content: View>: View {
  let url: URL
  let size: CGSize
  @ViewBuilder let content: (CGImage?) -> Content
  @EnvironmentObject var observableImageCache: ObservableImageCache

  var body: some View {
    content(observableImageCache.image(for: url, size: size))
  }
}
