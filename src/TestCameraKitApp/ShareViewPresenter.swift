import UIKit

protocol ShareViewPresenter {
  func presentFile(url: URL)
}

struct ShareViewPresenterImpl: ShareViewPresenter {
  let logger: Logger

  func presentFile(url: URL) {
    DispatchQueue.main.async {
      let state = UIApplication.shared.applicationState
      guard state == .active else {
        self.logger.log("Media chunk received, but application isn't active")
        return
      }
      let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
      topViewController?.present(activityVC, animated: true, completion: nil)
    }
  }
}

private var topViewController: UIViewController? {
  var topVc = UIApplication.shared.windows.first?.rootViewController
  while let newTopController = topVc?.presentedViewController {
    topVc = newTopController
  }
  return topVc
}
