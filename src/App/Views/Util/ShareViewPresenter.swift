import UIKit

protocol ShareViewPresenter {
  func presentFile(url: URL)
}

final class ShareViewPresenterImpl: ShareViewPresenter {
  init(application: UIApplication) {
    self.application = application
  }

  func presentFile(url: URL) {
    urls.append(url)
    DispatchQueue.main.async { [weak self] in
      self?.tryPresentActivityVc()
    }
  }

  private func tryPresentActivityVc() {
    guard application.applicationState == .active else {
      print("State not active, delaying presenting")
      return
    }
    guard !(application.windows.first?.topViewController is UIActivityViewController) else { return }
    tryDequeueUrl()
  }

  private func tryDequeueUrl() {
    guard !urls.isEmpty else { return }
    let url = urls.removeLast()
    let activityVc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    activityVc.completionWithItemsHandler = { [weak self] _, _, _, _ in
      self?.tryDequeueUrl()
    }
    application.windows.first?.topViewController?.present(activityVc, animated: true, completion: nil)
  }

  private var urls = [URL]()
  private let application: UIApplication
}
