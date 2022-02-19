import CommonUI
import UIKit
import Util

@MainActor
public final class TabRouter {
  public nonisolated init(
    lazyMain: Lazy<MainRouting>,
    lazyHistory: Lazy<HistoryRouting>,
    lazySettings: Lazy<SettingsRouting>,
    lazyTabBarViewController: Lazy<TabBarViewController>
  ) {
    self.lazyMain = lazyMain
    self.lazyHistory = lazyHistory
    self.lazySettings = lazySettings
    self.lazyTabBarViewController = lazyTabBarViewController
  }

  public var mainRouting: MainRouting? {
    selected(.mainTab) ? lazyMain.value : nil
  }

  public var historyRouting: HistoryRouting? {
    selected(.historyTab) ? lazyHistory.value : nil
  }

  public var settingsRouting: SettingsRouting? {
    selected(.settingsTab) ? lazySettings.value : nil
  }

  private func selected(_ tabIndex: Int) -> Bool {
    !(tabBarController.viewControllers ?? []).isEmpty && tabBarController.selectedIndex == tabIndex
  }

  private let lazyMain: Lazy<MainRouting>
  private let lazyHistory: Lazy<HistoryRouting>
  private let lazySettings: Lazy<SettingsRouting>
  private let lazyTabBarViewController: Lazy<TabBarViewController>

  private func checkInitialization() {
    let vcs = tabBarController.viewControllers ?? []
    guard vcs.isEmpty else { return }
    tabBarController.setup()
    tabBarController.set(
      mainViewController: lazyMain.value.viewController,
      historyViewController: lazyHistory.value.viewController,
      settingsViewController: lazySettings.value.viewController
    )
  }

  private var tabBarController: TabBarViewController {
    lazyTabBarViewController.value
  }
}

extension TabRouter: TabRouting {
  public func selectMain() {
    checkInitialization()
    tabBarController.selectedIndex = .mainTab
  }

  public func selectHistory() {
    checkInitialization()
    tabBarController.selectedIndex = .historyTab
  }

  public func selectSettings() {
    checkInitialization()
    tabBarController.selectedIndex = .settingsTab
  }

  public var viewController: UIViewController {
    tabBarController
  }
}

private extension Int {
  static var mainTab: Int { 0 }
  static var historyTab: Int { 1 }
  static var settingsTab: Int { 2 }
}
