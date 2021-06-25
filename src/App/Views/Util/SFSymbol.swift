import SwiftUI

enum SFSymbol: String {
  case checkmark = "checkmark.square"
  case play = "play.fill"
  case history = "list.bullet.below.rectangle"
  case settings = "gear"
  case plus
  case star = "star.fill"
  case contactUs = "pencil.and.ellipsis.rectangle"
  case assetLimit = "camera.rotate.fill"
  case assetLength = "clock.fill"
  case usedSpace = "tray.full.fill"
  case language = "textformat.abc"
  case theme = "square.righthalf.fill"
  case calendar
  case selectDevice = "camera.on.rectangle.fill"
  case trash
  case export = "square.stack.3d.up"
  case share = "arrowshape.turn.up.right"
  case camera
  case mic
  case photo
  case zoom = "magnifyingglass"
  case fov = "viewfinder"
  case fps30 = "goforward.30"
  case eye
  case speedometer
  case video
  case hare
  case ear
  case polarPattern = "timelapse"
  case deviceLocation = "skew"
  case restore = "arrow.counterclockwise"
  case orientation = "arrow.2.squarepath"
}

extension Image {
  init(sfSymbol: SFSymbol) {
    self.init(systemName: sfSymbol.rawValue)
  }
}

extension UIImage {
  convenience init?(sfSymbol: SFSymbol) {
    self.init(systemName: sfSymbol.rawValue)
  }
}
