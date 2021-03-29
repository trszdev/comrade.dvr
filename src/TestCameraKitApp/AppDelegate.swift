import UIKit
import Combine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    return true
  }
}

extension Publisher {
  func sinkAndStore() {
    // closure variables for debug purposes
    sink(receiveCompletion: { completion in
      switch completion {
      case let .failure(error):
        switch error {
        default:
          break
        }
      case .finished:
        break
      }
    }, receiveValue: { _ in
    }).storeUntilComplete()
  }
}

extension AnyCancellable {
  func storeUntilComplete() {
    store(in: &cancellables)
  }
}

private var cancellables = Set<AnyCancellable>()
