import UIKit

public final class TrackingViewController: UIViewController {
  public var viewDidLoadCallback: () -> Void = {}
  public var viewWillAppearCallback: (_ animated: Bool) -> Void = { _ in }
  public var viewDidAppearCallback: (_ animated: Bool) -> Void = { _ in }
  public var viewWillDisappearCallback: (_ animated: Bool) -> Void = { _ in }
  public var viewDidDisappearCallback: (_ animated: Bool) -> Void = { _ in }

  public init(
    _ childVC: UIViewController? = nil,
    viewDidLoad: @escaping () -> Void = {},
    viewWillAppear: @escaping (_ animated: Bool) -> Void = { _ in },
    viewDidAppear: @escaping (_ animated: Bool) -> Void = { _ in },
    viewWillDisappear: @escaping (_ animated: Bool) -> Void = { _ in },
    viewDidDisappear: @escaping (_ animated: Bool) -> Void = { _ in }
  ) {
    self.childVC = childVC
    viewDidLoadCallback = viewDidLoad
    viewWillAppearCallback = viewWillAppear
    viewDidAppearCallback = viewDidAppear
    viewWillDisappearCallback = viewWillDisappear
    viewDidDisappearCallback = viewDidDisappear
    super.init(nibName: nil, bundle: nil)
  }

  @discardableResult
  public static func installOnParent(
    _ parentVC: UIViewController,
    viewDidLoad: @escaping () -> Void = {},
    viewWillAppear: @escaping (_ animated: Bool) -> Void = { _ in },
    viewDidAppear: @escaping (_ animated: Bool) -> Void = { _ in },
    viewWillDisappear: @escaping (_ animated: Bool) -> Void = { _ in },
    viewDidDisappear: @escaping (_ animated: Bool) -> Void = { _ in }
  ) -> TrackingViewController {
    let result = TrackingViewController(
      viewDidLoad: viewDidLoad,
      viewWillAppear: viewWillAppear,
      viewDidAppear: viewDidAppear,
      viewWillDisappear: viewWillDisappear,
      viewDidDisappear: viewDidDisappear
    )
    add(child: result, to: parentVC)
    return result
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    if let childVC = childVC {
      add(child: childVC, to: self)
    } else {
      view.isUserInteractionEnabled = false
      view.isHidden = true
    }
    viewDidLoadCallback()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewWillAppearCallback(animated)
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewDidAppearCallback(animated)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewWillDisappearCallback(animated)
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewDidDisappearCallback(animated)
  }

  private let childVC: UIViewController?
}

private func add(child: UIViewController, to parent: UIViewController) {
  parent.addChild(child)
  parent.view.addSubview(child.view)
  child.view.translatesAutoresizingMaskIntoConstraints = false
  NSLayoutConstraint.activate([
    parent.view.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
    parent.view.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
    parent.view.topAnchor.constraint(equalTo: child.view.topAnchor),
    parent.view.bottomAnchor.constraint(equalTo: child.view.bottomAnchor),
  ])
  child.didMove(toParent: parent)
}
