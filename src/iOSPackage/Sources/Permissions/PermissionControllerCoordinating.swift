import UIKit
import SPPermissions
import SPPermissionsCamera
import SPPermissionsMicrophone
import SPPermissionsNotification
import Assets
import Util
import CommonUI
import Combine

public protocol PermissionControllerCoordinating: UIViewControllerProviding {
  func waitToClose() async
}

public final class PermissionControllerCoordinator: PermissionControllerCoordinating, SPPermissionsDelegate {
  public var viewController: UIViewController {
    navigationController
  }

  public nonisolated init(languagePublisher: CurrentValuePublisher<Language?>, permissions: [Permission]) {
    self.permissions = permissions
    cancellable = languagePublisher.receive(on: DispatchQueue.main).sink { [weak self] language in
      Task { @MainActor [weak self] in
        guard let self = self else { return }
        self.setLanguage(controller: self.controller, language: language)
        self.controller.tableView.reloadData()
      }
    }
    dataSource.language = languagePublisher.currentValue()
  }

  private func setLanguage(controller: SPPermissionsListController, language: Language?) {
    dataSource.language = language
    controller.headerText = language.string(.permissionsTitle)
    controller.titleText = language.string(.permissionsSubtitle)
    controller.footerText = language.string(.permissionsCaption)
  }

  private let permissions: [Permission]
  private let dataSource = DataSource()
  private var cancellable: AnyCancellable!

  private lazy var navigationController: UINavigationController = {
    let navigationController = UINavigationController(rootViewController: controller)
    navigationController.modalPresentationStyle = .formSheet
    navigationController.preferredContentSize = CGSize.init(width: 480, height: 560)
    return navigationController
  }()

  private lazy var controller: SPPermissionsListController = {
    let result = SPPermissions.list(permissions.map(\.spPermission))
    result.dataSource = dataSource
    result.delegate = self
    result.showCloseButton = true
    setLanguage(controller: result, language: dataSource.language)
    return result
  }()

  private var hideCompletion: (() -> Void)?

  public func waitToClose() async {
    await withCheckedContinuation { [weak self] continuation in
      self?.hideCompletion = { continuation.resume() }
    }
  }

  public func didHidePermissions(_ permissions: [SPPermissions.Permission]) {
    log.info()
    hideCompletion?()
  }
}
