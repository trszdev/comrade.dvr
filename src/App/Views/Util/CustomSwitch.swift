import SwiftUI

struct CustomSwitch: UIViewRepresentable {
  @Environment(\.theme) var theme: Theme
  @Binding var isOn: Bool
  var isEnabled = true

  func makeUIView(context: Context) -> UISwitch {
    let uiView = UISwitch()
    uiView.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(uiSwitch:)), for: .valueChanged)
    uiView.layer.masksToBounds = true
    uiView.layer.cornerRadius = 16
    return uiView
  }

  func updateUIView(_ uiView: UISwitch, context: Context) {
    uiView.isUserInteractionEnabled = isEnabled
    uiView.layer.opacity = isEnabled ? 1 : (isOn ? 0.4 : 0.3)
    uiView.isOn = isOn
    uiView.tintColor = UIColor(isEnabled ? theme.accentColorHover : theme.disabledTextColor)
    uiView.onTintColor = UIColor(isEnabled ? theme.accentColor : theme.disabledTextColor)
    uiView.layer.backgroundColor = uiView.tintColor.cgColor
    uiView.thumbTintColor = UIColor(theme.mainBackgroundColor)
  }

  class Coordinator {
    var isOn: Binding<Bool>?

    @objc func valueChanged(uiSwitch: UISwitch) {
      guard let isOn = isOn else { return }
      isOn.wrappedValue = uiSwitch.isOn
      uiSwitch.isOn = isOn.wrappedValue
    }
  }

  func makeCoordinator() -> Coordinator {
    let coordinator = Coordinator()
    coordinator.isOn = $isOn
    return coordinator
  }
}
