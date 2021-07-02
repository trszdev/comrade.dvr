import SwiftUI
import CameraKit

struct StartView<ViewModel: StartViewModel>: View {
  @Environment(\.theme) var theme: Theme
  @ObservedObject var viewModel: ViewModel
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    ZStack {
      theme.mainBackgroundColor.ignoresSafeArea()
      VStack(spacing: 0) {
        GeometryReader { geometry in
          ScrollView {
            devicesView(viewHeight: geometry.size.height)
          }
        }
        startHeaderView().background(theme.startHeaderBackgroundColor.ignoresSafeArea())
      }
    }
    .onReceive(viewModel.errors) { error in
      self.error = error
      showAlert = true
    }
    .alert(isPresented: $showAlert, content: alertContent)
    .navigationBarHidden(true)
  }

  func devicesView(viewHeight: CGFloat) -> some View {
    let columns = [GridItem(.adaptive(minimum: min(viewHeight, 120), maximum: 300))]
    return LazyVGrid(columns: columns, alignment: .center) {
      ForEach(viewModel.devices) { device in
        StartDeviceView(viewModel: device)
          .padding(7)
          .simultaneousGesture(TapGesture.from {
            viewModel.presentConfigureDeviceScreen(for: device)
          })
      }
    }
    .padding(10)
  }

  func startHeaderView() -> some View {
    VStack(spacing: 10) {
      HStack(spacing: 10) {
        theme.startIcon
        VStack(alignment: .leading) {
          Text(appLocale.fullAppName).foregroundColor(theme.textColor).font(.caption2)
          Text("\(appLocale.lastCaptureString): 10.12.2021 15:00").foregroundColor(theme.textColor).font(.caption2)
          Text("\(appLocale.usedSpaceString): 100mb / 10gb [100%]").foregroundColor(theme.textColor).font(.caption2)
        }
        Spacer()
      }
      StartButtonView(isBusy: viewModel.isStartButtonBusy)
        .frame(maxHeight: 50)
        .onTapGesture(perform: viewModel.start)
    }
    .padding(10)
  }

  private func alertContent() -> Alert {
    guard let error = error else { return Alert(title: Text("")) }
    switch error {
    case CKPermissionError.noPermission:
      return Alert(
        title: Text(appLocale.warningString),
        message: Text(appLocale.errorBody(error)),
        primaryButton: .cancel(),
        secondaryButton: .default(Text(appLocale.openSystemSettingsString), action: viewModel.openSettingsUrl)
      )
    default:
      return Alert(title: Text(appLocale.errorString), message: Text(appLocale.errorBody(error)))
    }
  }

  @State private var showAlert = false
  @State private var error: Error?
}

#if DEBUG

struct StartViewPreview: PreviewProvider {
  static var previews: some View {
    let viewModel = locator.resolve(StartViewModelBuilder.self).makeViewModel()
    StartView(viewModel: viewModel)
  }
}

#endif
