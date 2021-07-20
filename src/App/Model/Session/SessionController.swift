import Combine
import CameraKit
import Foundation
import UIKit
import AutocontainerKit

protocol SessionController {
  func tryStart()
  func stop()
  var status: SessionStatus { get }
  var statusPublisher: AnyPublisher<SessionStatus, Never> { get }
  var errorPublisher: AnyPublisher<Error, Never> { get }
}

final class SessionControllerImpl: AKBuilder, SessionController {
  func tryStart() {
    sessionQueue.sync {
      guard status == .notRunning else { return }
      statusSubject.value = .isStarting
      sessionMaker.makeSession()
        .compactMap { [weak self] (session, viewController) in
          self?.retainSession(session: session, viewController: viewController)
        }
        .catch { [weak self] (error: Error) -> Empty<SessionViewController, Never> in
          self?.statusSubject.value = .notRunning
          self?.errorSubject.send(error)
          return Empty()
        }
        .flatMap { (viewController: SessionViewController) in
          Deferred {
            viewController.present()
          }
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
  var statusPublisher: AnyPublisher<SessionStatus, Never> { statusSubject.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<Error, Never> { errorSubject.eraseToAnyPublisher() }

  private func retainSession(session: CKSession, viewController: SessionViewController) -> SessionViewController? {
    sessionQueue.sync {
      guard status == .isStarting else { return nil }
      Timer.publish(every: assetLengthSetting.value.value, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in
          self?.session?.requestMediaChunk()
        }
        .store(in: &cancellables)
      statusSubject.value = .isRunning
      self.session = session
      outputCancellable = session.outputPublisher
        .map { [weak self] mediaChunk in
          self?.sessionOutputSaver.save(mediaChunk: mediaChunk, sessionStartupInfo: session.startupInfo)
        }
        .sink(receiveCompletion: { _ in }, receiveValue: { })
      sessionViewController = viewController
      return viewController
    }
  }

  private let statusSubject = CurrentValueSubject<SessionStatus, Never>(.notRunning)
  private let errorSubject = PassthroughSubject<Error, Never>()
  private lazy var assetLengthSetting = resolve(AnySetting<AssetLengthSetting>.self)!
  private var session: CKSession?
  private weak var sessionViewController: UIViewController?
  private lazy var sessionMaker = resolve(SessionMaker.self)!
  private var cancellables = Set<AnyCancellable>()
  private let sessionQueue = DispatchQueue()
  private lazy var sessionOutputSaver = resolve(SessionOutputSaver.self)!
  private var outputCancellable: AnyCancellable!
}
