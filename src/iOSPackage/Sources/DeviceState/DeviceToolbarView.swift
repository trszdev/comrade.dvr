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
        .alert(isPresented: $showAlert) {
          Alert(
            title: Text(language.string(.error)),
            message: Text(language.string(.cantApplyConfiguration))
          )
        }
      }
    }

    ToolbarItem(placement: .principal) {
      Text(language.string(title))
        .foregroundColor(appearance.color(hasErrors ? .textColorDestructive : .textColorDefault))
        .font(.headline)
    }
  }
}
