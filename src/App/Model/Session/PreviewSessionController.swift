import Combine
import CameraKit
import Foundation
import SwiftUI
import AutocontainerKit

final class PreviewSessionController: SessionController {
  init(
    sessionViewControllerBuilder: SessionViewController.Builder,
    sessionViewBuilder: SessionViewBuilder,
    previewSessionViewModel: PreviewSessionViewModel
  ) {
    self.sessionViewControllerBuilder = sessionViewControllerBuilder
    self.sessionViewBuilder = sessionViewBuilder
    self.previewSessionViewModel = previewSessionViewModel
  }

  func tryStart() {
    statusSubject.value = .isRunning
    previewSessionViewModel.previews = [
      Image("PreviewBackCamera").resizable().aspectRatio(contentMode: .fill).eraseToAnyView(),
      Image("PreviewFrontCamera").resizable().aspectRatio(contentMode: .fill).eraseToAnyView(),
    ]
    previewSessionViewModel.onStop = { [weak self] in
      self?.stop()
    }
    let sessionview = sessionViewBuilder.makeView(viewModel: previewSessionViewModel, orientation: .portrait)
    let sessionVc = sessionViewControllerBuilder.makeViewController(
      orientation: .portrait,
      rootView: sessionview.eraseToAnyView()
    )
    viewController = sessionVc
    _ = sessionVc.present()
  }

  func stop() {
    statusSubject.value = .notRunning
    viewController?.dismiss(animated: true, completion: nil)
  }

  var status: SessionStatus { statusSubject.value }
  var statusPublisher: AnyPublisher<SessionStatus, Never> { statusSubject.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<Error, Never> { PassthroughSubject<Error, Never>().eraseToAnyPublisher() }

  private weak var viewController: UIViewController?
  private var cancellables = Set<AnyCancellable>()
  private let statusSubject = CurrentValueSubject<SessionStatus, Never>(.notRunning)
  private let sessionViewControllerBuilder: SessionViewController.Builder
  private let sessionViewBuilder: SessionViewBuilder
  private let previewSessionViewModel: PreviewSessionViewModel
}
