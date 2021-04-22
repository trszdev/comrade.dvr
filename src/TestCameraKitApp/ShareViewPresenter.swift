import UIKit

protocol ShareViewPresenter {
  func presentFile(url: URL)
}

final class ShareViewPresenterImpl: ShareViewPresenter {
  let logger: Logger

  init(logger: Logger) {
    self.logger = logger
  }

  func presentFile(url: URL) {
    urls.append(url)
    logger.log("Received url: \(url.path)")
    DispatchQueue.main.async { [weak self] in
      self?.tryPresentActivityVc()
    }
  }

  private func tryPresentActivityVc() {
    let state = UIApplication.shared.applicationState
    guard state == .active else {
      logger.log("Media chunk received, but application isn't active")
      return
    }
    guard !(topViewController is UIActivityViewController) else { return }
    tryDequeueUrl()
  }

  private func tryDequeueUrl() {
    guard !urls.isEmpty else { return }
    let url = urls.removeLast()
    let activityVc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    activityVc.completionWithItemsHandler = { [weak self] _, _, _, _ in
      self?.tryDequeueUrl()
    }
    topViewController?.present(activityVc, animated: true, completion: nil)
  }

  private var urls = [URL]()
}

private var topViewController: UIViewController? {
  var topVc = UIApplication.shared.windows.first?.rootViewController
  while let newTopController = topVc?.presentedViewController {
    topVc = newTopController
  }
  return topVc
}
