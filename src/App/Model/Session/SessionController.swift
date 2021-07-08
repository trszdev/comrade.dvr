import Combine
import CameraKit
import Foundation
import UIKit
import AutocontainerKit

protocol SessionController {
  func tryStart()
  func stop()
  var status: SessionStatus { get }
  var statusPublisher: AnyPublisher<SessionStatus, Error> { get }
}

final class SessionControllerImpl: AKBuilder, SessionController {
  func tryStart() {
    sessionQueue.sync {
      guard status == .notRunning else { return }
      statusSubject.value = .isStarting
      sessionMaker.makeSession()
        .zip(Just(0).setFailureType(to: Error.self).delay(for: 0.5, scheduler: RunLoop.main))
        .map(\.0)
        .compactMap { [weak self] (session, viewController) in
          guard let self = self else { return nil }
          return self.sessionQueue.sync {
            guard self.status == .isStarting else { return nil }
            self.statusSubject.value = .isRunning
            self.session = session
            self.sessionViewController = viewController
            return viewController
          }
        }
        .flatMap { (viewController: SessionViewController) in
          Deferred(createPublisher: viewController.present)
        }
        .catch { [weak self] (error: Error) -> Just<Void> in
          guard let self = self else { return Just(()) }
          self.statusSubject.value = .notRunning
          self.statusSubject.send(completion: .failure(error))
          return Just(())
        }
        .sink {}
        .store(in: &cancellables)
    }
  }

  func stop() {
    sessionQueue.sync {
      cancellables = Set()
      let deviceCount = (session?.cameras.count ?? 0) + (session?.microphone == nil ? 0 : 1)
      session?.outputPublisher
        .timeout(.seconds(0.5), scheduler: DispatchQueue.global(qos: .userInitiated))
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .prefix(deviceCount)
        .collect()
        .replaceError(with: [])
        .sink { [weak self] _ in
          guard let self = self else { return }
          self.sessionQueue.sync {
            self.session = nil
            self.statusSubject.value = .notRunning
          }
        }
        .store(in: &cancellables)
      sessionViewController?.dismiss(animated: true, completion: nil)
      session?.requestMediaChunk()
    }
  }

  var status: SessionStatus { statusSubject.value }
  var statusPublisher: AnyPublisher<SessionStatus, Error> { statusSubject.eraseToAnyPublisher() }

  private let statusSubject = CurrentValueSubject<SessionStatus, Error>(.notRunning)

  private var session: CKSession?
  private weak var sessionViewController: UIViewController?
  private lazy var sessionMaker = resolve(SessionMaker.self)!
  private var cancellables = Set<AnyCancellable>()
  private let sessionQueue = DispatchQueue()
}
