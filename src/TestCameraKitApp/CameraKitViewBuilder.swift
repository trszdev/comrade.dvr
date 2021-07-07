import CameraKit
import AutocontainerKit
import SwiftUI

protocol CameraKitViewBuilder {
  func makeView(session: CKSession, hostingVc: UIViewController) -> AnyView
}

final class CameraKitViewBuilderImpl: AKBuilder, CameraKitViewBuilder {
  func makeView(session: CKSession, hostingVc: UIViewController) -> AnyView {
    let logger = resolve(Logger.self)!
    logger.log("View created for session: \(session.configuration))")
    let viewModel = CameraKitViewModelImpl(
      session: session,
      logger: logger,
      shareViewPresenter: resolve(ShareViewPresenter.self)
    )
    viewModel.setupHandlers()
    viewModel.hostingVc = hostingVc
    return AnyView(CameraKitView(consoleView: resolve(ConsoleView<LogViewModelImpl>.self), viewModel: viewModel))
  }
}
