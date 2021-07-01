import SwiftUI
import Combine

protocol SessionViewModel: ObservableObject {
  var sessionViewController: SessionViewController? { get set }

  var previews: [AnyView] { get }
  func stopSession()
  var microphoneMuted: Bool { get set }
  var microphoneMutedPublished: Published<Bool> { get }
  var microphoneMutedPublisher: Published<Bool>.Publisher { get }

  var infoText: String { get }
  var infoTextPublished: Published<String> { get }
  var infoTextPublisher: Published<String>.Publisher { get }

  func scheduleDismissAlertTimer()
  var dismissAlertPublisher: AnyPublisher<Void, Never> { get }
}

class SessionViewModelImpl: SessionViewModel {
  var sessionViewController: SessionViewController?

  var previews: [AnyView] = [
    Color.blue.eraseToAnyView(),
    Color.green.eraseToAnyView(),
  ]

  func stopSession() {
    sessionViewController?.dismiss(animated: true, completion: nil)
  }

  @Published var microphoneMuted = false
  var microphoneMutedPublished: Published<Bool> { _microphoneMuted }
  var microphoneMutedPublisher: Published<Bool>.Publisher { $microphoneMuted }

  @Published var infoText: String = "asdasda sda da"
  var infoTextPublished: Published<String> { _infoText }
  var infoTextPublisher: Published<String>.Publisher { $infoText }

  func scheduleDismissAlertTimer() {
    dismissTimer?.invalidate()
    dismissTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [dismissAlertPublisherInternal] timer in
      guard timer.isValid else { return }
      dismissAlertPublisherInternal.send()
    }
  }

  var dismissAlertPublisher: AnyPublisher<Void, Never> { dismissAlertPublisherInternal.eraseToAnyPublisher() }

  private var dismissAlertPublisherInternal = PassthroughSubject<Void, Never>()
  private var dismissTimer: Timer?
}
