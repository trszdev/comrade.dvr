import Foundation

public enum CKAVCameraSessionError: Error {
  case cantAddDevice
  case cantConnectDevice
  case cantConfigureDevice(inner: Error)
  case runtimeError(inner: Error)
}

extension CKAVCameraSessionError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .cantAddDevice:
      return "Can't add device"
    case let .cantConfigureDevice(error):
      return "Can't configure device (\(error.localizedDescription))"
    case .cantConnectDevice:
      return "Can't connect device"
    case let .runtimeError(error):
      return "Runtime error (\(error.localizedDescription))"
    }
  }
}
