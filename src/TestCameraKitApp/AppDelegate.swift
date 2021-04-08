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

func printCurrentTime() {
  let time = DispatchTime.now().uptimeNanoseconds
  var seconds = Decimal(time)
  seconds *= 1e-9
  let fmt = NumberFormatter()
  fmt.numberStyle = .decimal
  fmt.maximumFractionDigits = 3
  print(">>> time: \(time), seconds: \(seconds)")
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
