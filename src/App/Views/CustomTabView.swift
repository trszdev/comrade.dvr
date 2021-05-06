import SwiftUI
import UIKit

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
    let tabVc = UITabBarController()
    tabVc.viewControllers = views.map(UIHostingController.init(rootView:))
    return tabVc
  }
}
