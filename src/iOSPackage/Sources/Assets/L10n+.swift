import Foundation

public extension L10n {
  func localized(for language: Language? = nil) -> String {
    NSLocalizedString(rawValue, bundle: language?.bundle ?? .module, comment: "")
  }
}
