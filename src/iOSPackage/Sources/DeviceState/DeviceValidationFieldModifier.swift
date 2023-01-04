import SwiftUI

struct DeviceValidationFieldModifier: ViewModifier {

  var hasError: Bool
  @Environment(\.appearance) var appearance

  func body(content: Content) -> some View {
    if hasError {
      content
        .foregroundColor(appearance.color(.textColorDestructive))
        .accentColor(appearance.color(.textColorDestructive))
    } else {
      content
    }
  }

}

extension View {
  func fieldValidation(hasError: Bool) -> some View {
    modifier(DeviceValidationFieldModifier(hasError: hasError))
  }

}
