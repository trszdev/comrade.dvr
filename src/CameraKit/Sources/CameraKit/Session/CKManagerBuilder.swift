import Foundation

public protocol CKManagerBuilder {
  func makeManager(infoPlistBundle: Bundle?, shouldPickNearest: Bool) -> CKManager
}
