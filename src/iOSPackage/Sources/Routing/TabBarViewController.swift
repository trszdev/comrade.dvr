import UIKit
import Combine
import Assets
import Util

public final class TabBarViewController: UITabBarController {
  public init(
    languagePublisher: CurrentValuePublisher<Language?>,
    appearancePublisher: CurrentValuePublisher<Appearance?>
  ) {
    self.languagePublisher = languagePublisher
    self.appearancePublisher = appearancePublisher
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setup() {
    languagePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in self?.updateUI() }
      .store(in: &cancellables)
    appearancePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in self?.updateUI() }
      .store(in: &cancellables)
  }

  public func set(
    mainViewController: UIViewController,
    historyViewController: UIViewController,
    settingsViewController: UIViewController
  ) {
    self.mainViewController = mainViewController
    self.historyViewController = historyViewController
    self.settingsViewController = settingsViewController
    viewControllers = [
      mainViewController,
      historyViewController,
      settingsViewController,
    ]
    updateUI()
  }

  private var mainViewController: UIViewController?
  private var historyViewController: UIViewController?
  private var settingsViewController: UIViewController?

  private func updateUI() {
    updateUI(language: languagePublisher.currentValue(), appearance: appearancePublisher.currentValue())
  }

  private func updateUI(language: Language?, appearance: Appearance?) {
    mainViewController?.tabBarItem = .init(
      title: language.string(.record),
      image: .init(systemName: "play"),
      selectedImage: .init(systemName: "play.fill")
    )
    historyViewController?.tabBarItem = .init(
      title: language.string(.history),
      image: .init(systemName: "list.bullet.rectangle"),
      selectedImage: .init(systemName: "list.bullet.rectangle.fill")
    )
    settingsViewController?.tabBarItem = .init(
      title: language.string(.settings),
      image: .init(systemName: "gearshape"),
      selectedImage: .init(systemName: "gearshape.fill")
    )
    if #available(iOS 15.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = .systemBackground
      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = appearance
    }
    overrideUserInterfaceStyle = appearance.interfaceStyle
  }

  private let languagePublisher: CurrentValuePublisher<Language?>
  private let appearancePublisher: CurrentValuePublisher<Appearance?>
  private var cancellables = Set<AnyCancellable>()
}
