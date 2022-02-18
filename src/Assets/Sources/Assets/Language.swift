import Foundation
import SwiftUI

public enum Language: String, CaseIterable {
  case ru
  case en

  internal var bundle: Bundle {
    if let path = Bundle.module.path(forResource: rawValue, ofType: "lproj") {
      return Bundle(path: path) ?? .module
    }
    return .module
  }
}

public extension Optional where Wrapped == Language {
  func string(_ key: L10n) -> String {
    key.localized(for: self)
  }
}
