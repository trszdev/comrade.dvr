import SwiftUI
import AutocontainerKit
import Combine

final class SettingsUsedSpaceCellViewBuilder: AKBuilder {
  func makeView() -> AnyView {
    let viewModel = SettingsUsedSpaceCellViewModel(mediaChunkRepository: resolve(MediaChunkRepository.self))
    return SettingsUsedSpaceCellView(viewModel: viewModel).eraseToAnyView()
  }
}

final class SettingsUsedSpaceCellViewModel: ObservableObject {
  init(mediaChunkRepository: MediaChunkRepository) {
    cancellable = mediaChunkRepository.totalFileSizePublisher.assignWeak(to: \.fileSize, on: self)
  }

  @Published private(set) var fileSize: FileSize?
  private var cancellable: AnyCancellable?
}

struct SettingsUsedSpaceCellView: View {
  @Environment(\.appLocale) var appLocale: AppLocale
  @ObservedObject var viewModel: SettingsUsedSpaceCellViewModel

  var body: some View {
    TableCellView(
      centerView: Text(appLocale.usedSpaceString).eraseToAnyView(),
      rightView: Text(appLocale.fileSize(viewModel.fileSize)).eraseToAnyView(),
      sfSymbol: .usedSpace,
      separator: [.bottom],
      isDisabled: true
    )
  }
}
