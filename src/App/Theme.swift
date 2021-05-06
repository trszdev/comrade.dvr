import SwiftUI

protocol Theme {
  var headerBackgroundColor: Color { get }
  var mainBackgroundColor: Color { get }
  var accentColor: Color { get }
  var accentColorHover: Color { get }
  var textColor: Color { get }
  var startIcon: Image { get }
  var startHeaderBackgroundColor: Color { get }
}

struct WhiteTheme: Theme {
  let headerBackgroundColor = Color("HeaderBackgroundColor")
  let mainBackgroundColor = Color("MainBackgroundColor")
  let accentColor = Color("AccentColor")
  let accentColorHover = Color("AccentColorHover")
  let textColor = Color("TextColor")
  let startIcon = Image("StartIcon")
  let startHeaderBackgroundColor = Color.white
}

struct DarkTheme: Theme {
  let headerBackgroundColor = Color("HeaderBackgroundColorDark")
  let mainBackgroundColor = Color("MainBackgroundColorDark")
  let accentColor = Color("AccentColorDark")
  let accentColorHover = Color("AccentColorHoverDark")
  let textColor = Color("TextColorDark")
  let startIcon = Image("StartIconDark")
  let startHeaderBackgroundColor = Color.black
}
