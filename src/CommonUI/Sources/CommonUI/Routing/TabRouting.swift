@MainActor
public protocol TabRouting: UIViewControllerProviding, AnyObject {
  var mainRouting: MainRouting? { get }
  var historyRouting: HistoryRouting? { get }
  var settingsRouting: SettingsRouting? { get }
  func selectMain()
  func selectHistory()
  func selectSettings()
}
