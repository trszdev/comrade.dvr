import UIKit

protocol Haptics {
  func hover()
  func warn()
  func error()
  func success()
}

struct HapticsImpl: Haptics {
  func hover() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
  }

  func warn() {
    UINotificationFeedbackGenerator().notificationOccurred(.warning)
  }

  func error() {
    UINotificationFeedbackGenerator().notificationOccurred(.error)
  }

  func success() {
    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }
}
