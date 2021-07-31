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
            devicesView(size: geometry.size)
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

  func devicesView(size: CGSize) -> some View {
    let minDimenstion = min(size.width, size.height)
    let minItemSize = max(minDimenstion / 2 - 20, 10)
    let gridSize: GridItem.Size
    if minItemSize < 120 {
      gridSize = .adaptive(minimum: 120, maximum: 300)
    } else if minItemSize > 300 {
      gridSize = .adaptive(minimum: 300, maximum: 300)
    } else {
      gridSize = .adaptive(minimum: minItemSize, maximum: 300)
    }
    return LazyVGrid(columns: [GridItem(gridSize)], alignment: .center) {
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
    let unavailableString = appLocale.unavailableString.lowercased()
    let lastCaptureString = viewModel.lastCapture.flatMap(appLocale.full(date:)) ?? unavailableString
    var usedSpaceString = unavailableString
    if let usedSpace = viewModel.usedSpace {
      if let limitSize = viewModel.spaceLimit {
        let ratio = Double(usedSpace.bytes) / Double(limitSize.bytes)
        usedSpaceString = "\(appLocale.fileSize(usedSpace)) / \(appLocale.fileSize(limitSize)) [\(Int(ratio * 100))%]"
      } else {
        usedSpaceString = appLocale.fileSize(usedSpace)
      }
    }
    return VStack(spacing: 10) {
      HStack(spacing: 10) {
        theme.startIcon
        VStack(alignment: .leading) {
          Text(appLocale.fullAppName).foregroundColor(theme.textColor).font(.caption2)
          Text("\(appLocale.lastCaptureString): \(lastCaptureString)").foregroundColor(theme.textColor).font(.caption2)
          Text("\(appLocale.usedSpaceString): \(usedSpaceString)").foregroundColor(theme.textColor).font(.caption2)
        }
        Spacer()
      }
      StartButtonView(isBusy: isStartButtonBusy, isDisabled: isStartButtonDisabled)
        .frame(maxHeight: 50)
        .onTapGesture(perform: viewModel.start)
    }
    .padding(10)
  }

  private var isStartButtonBusy: Bool {
    switch viewModel.sessionStatus {
    case .isRunning, .isStarting:
      return true
    case .none, .notRunning:
      return false
    }
  }

  private var isStartButtonDisabled: Bool {
    viewModel.sessionStatus == nil
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
