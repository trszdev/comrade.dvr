import SwiftUI
import MessageUI

struct SettingsContactUsCellView: View {
  struct Builder {
    let navigationViewPresenter: NavigationViewPresenter

    func makeView() -> SettingsContactUsCellView {
      SettingsContactUsCellView(navigationViewPresenter: navigationViewPresenter)
    }
  }

  let navigationViewPresenter: NavigationViewPresenter
  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    SettingsCellView(
      text: appLocale.contactUsString,
      rightText: appLocale.appContactEmail,
      sfSymbol: .contactUs,
      onTap: onTap
    )
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
      UIApplication.shared.canOpenURL(mailtoUrl)
    else {
      return
    }
    UIApplication.shared.open(mailtoUrl, options: [:], completionHandler: nil)
  }
}
