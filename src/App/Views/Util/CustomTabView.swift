import SwiftUI

struct CustomTabView: UIViewControllerRepresentable {
  let views: [AnyView]
  @State var labels: [(SFSymbol, String)]
  @Environment(\.theme) var theme: Theme

  func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
    uiViewController.tabBar.barTintColor = UIColor(theme.mainBackgroundColor)
    uiViewController.tabBar.tintColor = UIColor(theme.accentColor)
    uiViewController.tabBar.unselectedItemTintColor = UIColor(theme.accentColorHover)
    let vcs = uiViewController.viewControllers ?? []
    for (tag, (hostingVc, (sfSymbol, text))) in zip(vcs, labels).enumerated() {
      let image = UIImage(systemName: sfSymbol.rawValue)
      let tabBarItem = UITabBarItem(title: text, image: image, tag: tag)
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

private class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
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
