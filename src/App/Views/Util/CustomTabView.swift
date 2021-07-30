import SwiftUI
import Accessibility

struct CustomTabView: UIViewControllerRepresentable {
  let views: [AnyView]
  let labels: [CustomTabViewLabel]
  @Environment(\.theme) var theme: Theme
  @Environment(\.appLocale) var appLocale: AppLocale

  func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
    uiViewController.tabBar.barTintColor = UIColor(theme.mainBackgroundColor)
    uiViewController.tabBar.tintColor = UIColor(theme.accentColor)
    uiViewController.tabBar.unselectedItemTintColor = UIColor(theme.accentColorHover)
    let vcs = uiViewController.viewControllers ?? []
    for (tag, (hostingVc, label)) in zip(vcs, labels).enumerated() {
      let image = UIImage(systemName: label.sfSymbol.rawValue)
      let tabBarItem = UITabBarItem(title: label.localize(appLocale), image: image, tag: tag)
      tabBarItem.accessibilityLabel = label.accessibility.rawValue
      hostingVc.tabBarItem = tabBarItem
    }
  }

  func makeUIViewController(context: Context) -> UITabBarController {
    let tabVc = CustomTabBarController()
    tabVc.viewControllers = views.map(UIHostingController.init(rootView:))
    tabVc.delegate = tabVc
    return tabVc
  }
}

struct CustomTabViewLabel {
  let sfSymbol: SFSymbol
  let accessibility: Accessibility
  let localize: (AppLocale) -> String
}

private class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    updateAllTabsExceptCurrent()
  }

  func updateAllTabsExceptCurrent() {
    var hostingVcs = viewControllers?.compactMap { $0 as? UIHostingController<AnyView> } ?? []
    for index in 0..<hostingVcs.count where index != selectedIndex {
      hostingVcs[index] = UIHostingController(rootView: hostingVcs[index].rootView)
    }
    setViewControllers(hostingVcs, animated: false)
  }

  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    viewController.navigationController?.isNavigationBarHidden = true
  }
}
