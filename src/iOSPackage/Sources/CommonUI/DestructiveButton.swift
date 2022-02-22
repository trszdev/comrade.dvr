import SwiftUI

public struct DestructiveButton<Label: View>: View {
  public init(action: @escaping () -> Void, label: @escaping () -> Label) {
    self.action = action
    self.label = label
  }

  public var body: some View {
    if #available(iOS 15.0, *) {
      Button(role: .destructive, action: action, label: label)
    } else {
      Button(action: action, label: label)
    }
  }

  private var action: () -> Void
  @ViewBuilder private var label: () -> Label
}
