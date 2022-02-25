@MainActor
public protocol TabRouting: UIViewControllerProviding, AnyObject {
  var startRouting: StartRouting? { get }
  var historyRouting: HistoryRouting? { get }
  var settingsRouting: SettingsRouting? { get }
  func selectStart()
  func selectHistory()
  func selectSettings()
}
