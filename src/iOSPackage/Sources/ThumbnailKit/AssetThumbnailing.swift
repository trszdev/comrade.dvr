import CoreGraphics
import Foundation

public protocol AssetThumbnailing {
  func thumbnail(for url: URL, size: CGSize) async throws -> CGImage
}
