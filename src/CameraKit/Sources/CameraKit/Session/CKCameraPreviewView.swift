import SwiftUI
import UIKit

// https://www.swiftbysundell.com/tips/inline-wrapping-of-uikit-or-appkit-views-within-swiftui/
public struct CKCameraPreviewView: UIViewRepresentable {
  public init(
    _ makeView: @escaping @autoclosure () -> UIView,
    updater update: @escaping (UIView, Context) -> Void
  ) {
    self.makeView = makeView
    self.update = update
  }

  public func makeUIView(context: Context) -> UIView {
    makeView()
  }

  public func updateUIView(_ view: UIView, context: Context) {
    update(view, context)
  }

  private let makeView: () -> UIView
  private let update: (UIView, Context) -> Void
}

public extension CKCameraPreviewView {
  init(
    _ makeView: @escaping @autoclosure () -> UIView,
    updater update: @escaping (UIView) -> Void
  ) {
    self.makeView = makeView
    self.update = { view, _ in update(view) }
  }

  init(_ makeView: @escaping @autoclosure () -> UIView) {
    self.makeView = makeView
    self.update = { _, _ in }
  }
}
