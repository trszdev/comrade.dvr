import Foundation

public extension Bool {
  static func chance(_ ratio: Double) -> Bool {
    Double.random(in: 0...1) < ratio
  }
}
