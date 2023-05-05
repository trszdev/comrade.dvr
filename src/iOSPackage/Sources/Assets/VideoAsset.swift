import Foundation

public enum VideoAsset: String {
  case preview = "preview.mp4"

  public var url: URL {
    Bundle.module.url(forResource: rawValue, withExtension: nil)!
  }
}
