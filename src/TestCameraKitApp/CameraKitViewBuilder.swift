import CameraKit
import AutocontainerKit

protocol CameraKitViewBuilder {
  func makeView(session: CKSession) -> CameraKitView<CameraKitViewModelImpl, LogViewModelImpl>
}

struct CameraKitViewBuilderImpl: CameraKitViewBuilder {
  let logger: Logger
  let shareViewPresenter: ShareViewPresenter
  let consoleView: ConsoleView<LogViewModelImpl>

  func makeView(session: CKSession) -> CameraKitView<CameraKitViewModelImpl, LogViewModelImpl> {
    CameraKitView(
      consoleView: consoleView,
      viewModel: CameraKitViewModelImpl(session: session, logger: logger, shareViewPresenter: shareViewPresenter)
    )
  }
}
