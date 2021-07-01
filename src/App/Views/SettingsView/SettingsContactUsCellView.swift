import SwiftUI
import MessageUI

struct SettingsContactUsCellView: View {
  struct Builder {
    let application: UIApplication
    let navigationViewPresenter: NavigationViewPresenter

    func makeView() -> SettingsContactUsCellView {
      SettingsContactUsCellView(application: application, navigationViewPresenter: navigationViewPresenter)
    }
  }

  let application: UIApplication
  let navigationViewPresenter: NavigationViewPresenter
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    TableCellView(
      centerView: Text(appLocale.contactUsString).eraseToAnyView(),
      rightView: Text(appLocale.appContactEmail).eraseToAnyView(),
      sfSymbol: .contactUs
    )
    .onTapGesture(perform: onTap)
  }

  private func onTap() {
    guard MFMailComposeViewController.canSendMail() else {
      return tryOpenMailtoURL()
    }
    let mail = MFMailComposeViewController()
    mail.setToRecipients([appLocale.appContactEmail])
    mail.setMessageBody("Feedback: \(appLocale.fullAppName)", isHTML: false)
    navigationViewPresenter.presentViewController(viewController: mail)
  }

  private func tryOpenMailtoURL() {
    guard let mailtoUrl = URL(string: "mailto:\(appLocale.appContactEmail)"),
      application.canOpenURL(mailtoUrl)
    else {
      return
    }
    application.open(mailtoUrl, options: [:], completionHandler: nil)
  }
}
