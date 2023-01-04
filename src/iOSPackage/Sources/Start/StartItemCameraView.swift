import SwiftUI
import DeviceState
import LocalizedUtils
import Assets

struct StartItemCameraView: View {
  let shouldUpgrade: Bool
  let state: DeviceCameraState
  let action: () -> Void

  @Environment(\.language) private var language
  @Environment(\.appearance) private var appearance

  var body: some View {
    let enabled = !shouldUpgrade && state.enabled
    let opacity = (shouldUpgrade || state.isLocked) ? 0.5 : 1
    var color = (enabled ? Color.accentColor : Color.gray).opacity(opacity)
    let hasError = state.hasErrors && !shouldUpgrade
    if hasError {
      color = appearance.color(.textColorDestructive).opacity(opacity)
    }

    return StartItemView(action: action, enabled: enabled, color: color) {
      VStack(alignment: .leading, spacing: 0) {
        Text(language.string(state.deviceName))
          .fontWeight(.medium)
          .foregroundColor(color)
          .multilineTextAlignment(.leading)
          .lineSpacing(0)
          .lineLimit(2)
          .font(.title3)
          .padding(.bottom, 5)

        Text(language.resolution(state.configuration.resolution))

        Text(language.fps(state.configuration.fps))

        Text(language.quality(state.configuration.quality))

        Spacer()

        HStack {
          if shouldUpgrade {
            Text(language.string(.pro))
              .foregroundColor(appearance.color(.proColor))
          }

          Spacer()

          if state.isLocked {
            ProgressView()
          } else {
            Image(systemName: hasError ? "exclamationmark.circle" : "camera")
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
