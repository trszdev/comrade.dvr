import Swinject
import SwinjectExtensions
import SwinjectAutoregistration

public enum DeviceStateAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container.autoregister(DeviceCameraView.self, initializer: DeviceCameraView.init(store:))
    container.autoregister(DeviceMicrophoneView.self, initializer: DeviceMicrophoneView.init(store:))
  }
}
