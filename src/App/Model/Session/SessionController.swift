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
  override init(locator: AKLocator) {
    super.init(locator: locator)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willResignActiveNotification),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  @objc private func willResignActiveNotification() {
    guard session != nil else { return }
    wasStoppedByApp = true
    stopInternal()
  }

  @objc private func didBecomeActive() {
    guard wasStoppedByApp else { return }
    tryStart()
  }

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
    wasStoppedByApp = false
    stopInternal()
  }

  private func stopInternal() {
    sessionQueue.sync {
      cancellables = Set()
      let deviceCount = (session?.cameras.count ?? 0) + (session?.microphone == nil ? 0 : 1)
      session?.outputPublisher
        .timeout(.seconds(0.5), scheduler: DispatchQueue.global(qos: .userInitiated))
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .prefix(deviceCount)
        .collect()
        .replaceError(with: [])
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          self.sessionQueue.sync {
            self.application.isIdleTimerDisabled = false
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
      application.isIdleTimerDisabled = true
      self.session = session
      outputCancellable = session.outputPublisher
        .map { [weak self] mediaChunk in
          guard let self = self, let startupInfo = self.session?.startupInfo else { return }
          self.sessionOutputSaver.save(mediaChunk: mediaChunk, sessionStartupInfo: startupInfo)
        }
        .sink(receiveCompletion: { _ in }, receiveValue: { })
      sessionViewController = viewController
      return viewController
    }
  }

  private lazy var application = resolve(UIApplication.self)!
  private var wasStoppedByApp = false
  private let statusSubject = CurrentValueSubject<SessionStatus, Never>(.notRunning)
  private let errorSubject = PassthroughSubject<Error, Never>()
  private lazy var assetLengthSetting = resolve(AnySetting<AssetLengthSetting>.self)!
  private var session: CKSession?
  private weak var sessionViewController: UIViewController?
  private lazy var sessionMaker = resolve(SessionMaker.self)!
  private var cancellables = Set<AnyCancellable>()
  private let sessionQueue = DispatchQueue()
  private lazy var sessionOutputSaver = resolve(SessionOutputSaver.self)!
  private var outputCancellable: AnyCancellable?
}
