import SwiftUI
import MessageUI

struct SettingsContactUsCellView: View {
  @Environment(\.appLocale) var appLocale: AppLocale
  let viewPresenter: ViewPresenter

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
    viewPresenter.presentViewController(viewController: mail)
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
