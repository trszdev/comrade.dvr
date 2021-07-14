import SwiftUI
import CameraKit
import AutocontainerKit

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
    if let selectedDay = viewModel.selectedDay, let selectedDevice = viewModel.selectedDevice {
      return GeometryReader { geometry in
        VStack(spacing: 0) {
          menuView(selectedDevice: selectedDevice, selectedDay: selectedDay)
          playerView(height: geometry.size.height)
          tableView
        }
        .background(theme.mainBackgroundColor.ignoresSafeArea())
        .navigationBarHidden(true)
      }
      .eraseToAnyView()
    }
    return EmptyView().eraseToAnyView()
  }

  func menuView(selectedDevice: CKDeviceID, selectedDay: Date) -> some View {
    HistoryMenuView(
      title: appLocale.deviceName(selectedDevice),
      subtitle: appLocale.timeOnly(date: selectedDay),
      didTapSelectDay: viewModel.presentSelectDayScreen,
      didTapSelectDevice: viewModel.presentSelectDeviceScreen
    )
  }

  func playerView(height: CGFloat) -> some View {
    // use avPlayer with viewModel.selectedPlayerUrl
    let idealHeight = min(height / 2, 300)
    return Rectangle()
      .overlay(
        Image(sfSymbol: .play)
          .fitResizable
          .foregroundColor(.white)
          .frame(maxWidth: 50)
      )
      .frame(height: idealHeight)
      .background(Color.red.edgesIgnoringSafeArea(.horizontal).frame(height: idealHeight))
  }
}

#if DEBUG

struct HistoryViewPreview: PreviewProvider {
  static var previews: some View {
    locator.resolve(HistoryViewBuilder.self).makeView()
  }
}

#endif
