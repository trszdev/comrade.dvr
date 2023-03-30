import Foundation
import UIKit

public enum Orientation: Hashable, Codable {
  case portrait
  case landscapeLeft
  case landscapeRight
  case portraitUpsideDown

  public var interfaceOrientation: UIInterfaceOrientation {
    switch self {
    case .portrait:
      return .portrait
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    case .portraitUpsideDown:
      return .portraitUpsideDown
    }
  }

  public static func from(_ orientation: UIInterfaceOrientation) -> Self? {
    switch orientation {
    case .unknown:
      return nil
    case .portrait:
      return portrait
    case .portraitUpsideDown:
      return .portraitUpsideDown
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    @unknown default:
      return nil
    }
  }
}
