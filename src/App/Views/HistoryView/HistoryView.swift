import SwiftUI
import CameraKit
import AutocontainerKit
import AVKit

final class HistoryViewBuilder: AKBuilder {
  func makeView() -> AnyView {
    HistoryView(
      viewModel: resolve(HistoryViewModelImpl.self),
      tableView: resolve(HistoryTableViewBuilder.self).makeView()
    )
    .eraseToAnyView()
  }
}

struct HistoryView<ViewModel: HistoryViewModel>: View {
  @Environment(\.theme) var theme: Theme
  @Environment(\.appLocale) var appLocale: AppLocale
  let viewModel: ViewModel
  let tableView: AnyView

  var body: some View {
    guard let playerUrl = viewModel.selectedPlayerUrl,
      let selectedDay = viewModel.selectedDay,
      let selectedDevice = viewModel.selectedDevice
    else {
      return Text(appLocale.emptyString).foregroundColor(theme.textColor).eraseToAnyView()
    }
    return GeometryReader { geometry in
      VStack(spacing: 0) {
        menuView(selectedDevice: selectedDevice, selectedDay: selectedDay)
        playerView(height: geometry.size.height, playerUrl: playerUrl)
        tableView
      }
      .background(theme.mainBackgroundColor.ignoresSafeArea())
      .navigationBarHidden(true)
    }
    .background(theme.mainBackgroundColor.ignoresSafeArea())
    .navigationBarHidden(true)
    .eraseToAnyView()
  }

  func menuView(selectedDevice: CKDeviceID, selectedDay: Date) -> some View {
    HistoryMenuView(
      title: appLocale.deviceName(selectedDevice),
      subtitle: appLocale.day(date: selectedDay),
      didTapSelectDay: viewModel.presentSelectDayScreen,
      didTapSelectDevice: viewModel.presentSelectDeviceScreen
    )
  }

  func playerView(height: CGFloat, playerUrl: URL) -> some View {
    let idealHeight = min(height / 2, 300)
    return VideoPlayer(player: AVPlayer(url: playerUrl))
      .frame(height: idealHeight)
      .background(Color.black.edgesIgnoringSafeArea(.horizontal).frame(height: idealHeight))
  }
}

#if DEBUG

struct HistoryViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(HistoryViewBuilder.self).makeView()
  }
}

#endif
