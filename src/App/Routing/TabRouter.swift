import CommonUI
import UIKit
import Util

@MainActor
final class TabRouter {
  nonisolated init(
    lazyMain: Lazy<MainRouting>,
    lazyHistory: Lazy<HistoryRouting>,
    lazySettings: Lazy<SettingsRouting>
  ) {
    self.lazyMain = lazyMain
    self.lazyHistory = lazyHistory
    self.lazySettings = lazySettings
  }

  var mainRouting: MainRouting? {
    selected(.mainTab) ? lazyMain.value : nil
  }

  var historyRouting: HistoryRouting? {
    selected(.historyTab) ? lazyHistory.value : nil
  }

  var settingsRouting: SettingsRouting? {
    selected(.settingsTab) ? lazySettings.value : nil
  }

  private func selected(_ tabIndex: Int) -> Bool {
    !(tabBarController.viewControllers ?? []).isEmpty && tabBarController.selectedIndex == tabIndex
  }

  private let lazyMain: Lazy<MainRouting>
  private let lazyHistory: Lazy<HistoryRouting>
  private let lazySettings: Lazy<SettingsRouting>

  private func checkInitialization() {
    let vcs = tabBarController.viewControllers ?? []
    guard vcs.isEmpty else { return }
    tabBarController.viewControllers = [
      lazyMain.value.viewController,
      lazyHistory.value.viewController,
      lazySettings.value.viewController,
    ]
    lazyMain.value.viewController.tabBarItem = .init(
      title: "Start",
      image: .init(systemName: "play"),
      selectedImage: .init(systemName: "play.fill")
    )
    lazyHistory.value.viewController.tabBarItem = .init(
      title: "History",
      image: .init(systemName: "list.bullet.rectangle"),
      selectedImage: .init(systemName: "list.bullet.rectangle.fill")
    )
    lazySettings.value.viewController.tabBarItem = .init(
      title: "Settings",
      image: .init(systemName: "gearshape"),
      selectedImage: .init(systemName: "gearshape.fill")
    )
  }

  private lazy var tabBarController = UITabBarController()
}

extension TabRouter: TabRouting {
  func selectMain() {
    checkInitialization()
    tabBarController.selectedIndex = .mainTab
  }

  func selectHistory() {
    checkInitialization()
    tabBarController.selectedIndex = .historyTab
  }

  func selectSettings() {
    checkInitialization()
    tabBarController.selectedIndex = .settingsTab
  }

  var viewController: UIViewController {
    tabBarController
  }
}

private extension Int {
  static var mainTab: Int { 0 }
  static var historyTab: Int { 1 }
  static var settingsTab: Int { 2 }
}
