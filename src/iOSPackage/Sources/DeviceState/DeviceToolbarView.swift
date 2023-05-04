import SwiftUI
import Assets

struct DeviceToolbarView: ToolbarContent {
  var hasErrors = false
  var isLoading = false
  var title: L10n = .microphone
  @Binding var showAlert: Bool
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance

  var body: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      if isLoading {
        ProgressView()
      } else if hasErrors {
        Button {
          showAlert = true
        } label: {
          Image(systemName: "exclamationmark.circle")
            .foregroundColor(appearance.color(.textColorDestructive))
        }
        .disabled(true)
      }
    }

    ToolbarItem(placement: .principal) {
      VStack {
        Text(language.string(title))
          .foregroundColor(appearance.color(hasErrors ? .textColorDestructive : .textColorDefault))
          .font(.headline)

        if hasErrors {
          Text(language.string(.cantApplyConfiguration))
            .foregroundColor(appearance.color(.textColorDisabled))
            .font(.caption)
        }
      }

    }
  }
}
