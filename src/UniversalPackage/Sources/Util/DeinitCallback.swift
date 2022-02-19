import Foundation

@objc public final class DeinitCallback: NSObject {
  public var callback: () -> Void = {}

  deinit {
    callback()
  }
}

private var deinitCallbackKey = "DEINITCALLBACK"

public extension NSObject {
  func deinitCallback(socket: inout String) -> DeinitCallback {
    if let deinitCallback = objc_getAssociatedObject(self, &socket) as? DeinitCallback {
      return deinitCallback
    } else {
      let rem = DeinitCallback()
      objc_setAssociatedObject(self, &socket, rem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return rem
    }
  }

  func deinitCallback() -> DeinitCallback {
    deinitCallback(socket: &deinitCallbackKey)
  }
}
