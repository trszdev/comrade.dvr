import SwiftUI

struct StartView<ViewModel: StartViewModel>: View {
  @Environment(\.theme) var theme: Theme
  @StateObject var viewModel: ViewModel
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    ZStack {
      theme.mainBackgroundColor.ignoresSafeArea()
      VStack(spacing: 0) {
        CustomScrollView {
          devicesView()
        }
        startHeaderView()
          .background(theme.startHeaderBackgroundColor.ignoresSafeArea())
      }
    }
  }

  func devicesView() -> some View {
    let columns = [GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 10)]
    return LazyVGrid(columns: columns, alignment: .center) {
      ForEach(viewModel.devices) { device in
        StartDeviceView(device: device) {
          viewModel.presentConfigureDeviceScreen(for: device)
        }
      }
      if viewModel.canAddNewDevice {
        StartDeviceAddView {
          viewModel.presentAddNewDeviceScreen()
        }
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
          Text("\(appLocale.updatedAtString): 10.03.2021 14:88").foregroundColor(theme.textColor).font(.caption2)
          Text("\(appLocale.usedSpaceString): 100mb / 10gb [100%]").foregroundColor(theme.textColor).font(.caption2)
        }
        Spacer()
      }
      StartButtonView().frame(maxHeight: 50)
    }
    .padding(10)
  }
}

#if DEBUG

struct StartViewPreview: PreviewProvider {
  static var previews: some View {
    let viewModel = StartViewModelImpl(devices: [true, false, false], canAddNewDevice: true)
    StartView(viewModel: viewModel)
      .environment(\.theme, DarkTheme())
  }
}

#endif
