import SwiftUI

enum SFSymbol: String {
  case play = "play.fill"
  case history = "list.bullet.below.rectangle"
  case settings = "gear"
  case plus
}

extension Image {
  init(sfSymbol: SFSymbol) {
    self.init(systemName: sfSymbol.rawValue)
  }
}
