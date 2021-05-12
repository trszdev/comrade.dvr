import SwiftUI

extension TapGesture {
  static func from(tapGesture: @escaping () -> Void) -> some Gesture {
    TapGesture().onEnded(tapGesture)
  }
}
