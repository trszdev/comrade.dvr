import SwiftUI
import DeviceState
import LocalizedUtils
import Assets

struct StartItemMicrophoneView: View {
  let state: DeviceMicrophoneState
  let action: () -> Void

  @Environment(\.language) private var language
  @Environment(\.appearance) private var appearance

  var body: some View {
    let enabled = state.enabled
    let opacity = state.isLocked ? 0.5 : 1
    var color = (enabled ? Color.accentColor : Color.gray).opacity(opacity)
    let hasError = state.hasErrors
    if hasError {
      color = appearance.color(.textColorDestructive).opacity(opacity)
    }

    return StartItemView(action: action, enabled: enabled, color: color) {
      VStack(alignment: .leading, spacing: 0) {
        Text(language.string(.microphone))
          .fontWeight(.medium)
          .foregroundColor(color)
          .multilineTextAlignment(.leading)
          .lineSpacing(0)
          .lineLimit(2)
          .font(.title3)
          .padding(.bottom, 5)

        Text(language.polarPattern(state.configuration.polarPattern))

        Text(language.quality(state.configuration.quality))

        Spacer()

        HStack {
          Spacer()

          if state.isLocked {
            ProgressView()
          } else {
            Image(systemName: hasError ? "exclamationmark.circle" : "mic")
              .foregroundColor(color)
          }
        }
      }
      .padding(15)
      .font(.callout)
      .minimumScaleFactor(0.5)
      .foregroundColor(
        appearance.color(.textColorDisabled)
          .opacity(opacity)
      )
    }
  }
}
