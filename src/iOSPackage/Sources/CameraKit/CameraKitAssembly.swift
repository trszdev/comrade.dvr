import Swinject
import SwinjectExtensions
import SwinjectAutoregistration
import Device

public enum CameraKitAssembly: SharedAssembly {
  case shared

  public func assemble(container: Container) {
    container.registerInternalConfigurator()
    container.registerMonitor()
    container.registerURLMaker()
    container.registerFrontRecorder()
    container.registerBackRecorder()
    container.registerAudioRecorder()
    container.registerService()
    container.registerIndexer()
  }
}

private extension Container {
  static var frontCameraRecorder: String { "frontCameraRecorder" }
  static var backCameraRecorder: String { "backCameraRecorder" }
  static var internalSessionConfigurator: String { "internalSessionConfigurator" }
  static var internalSessionMonitor: String { "internalSessionMonitor" }

  func registerIndexer() {
    self
      .autoregister(DeviceConfigurationIndexer.self, initializer: DeviceConfigurationIndexerImpl.init)
      .inObjectScope(.transient)
  }

  func registerInternalConfigurator() {
    self
      .autoregister(SessionConfiguratorImpl.self, initializer: SessionConfiguratorImpl.init)
      .implements(SessionConfigurator.self, name: Self.internalSessionConfigurator)
      .inObjectScope(.transient)
  }

  func registerMonitor() {
    self
      .registerInstance(SessionMonitorImpl())
      .implements(SessionMonitor.self, name: Self.internalSessionMonitor)
      .inObjectScope(.container)
  }

  func registerURLMaker() {
    self
      .autoregister(URLMaker.self, initializer: URLMaker.init)
      .inObjectScope(.transient)
  }

  func registerFrontRecorder() {
    self
      .register(VideoRecorder.self, name: Self.frontCameraRecorder) { resolver in
        let urlMaker = resolver.resolve(URLMaker.self)!
        return VideoRecorderImpl(urlMaker: urlMaker.frontCamera)
      }
      .inObjectScope(.container)
  }

  func registerBackRecorder() {
    self
      .register(VideoRecorder.self, name: Self.backCameraRecorder) { resolver in
        let urlMaker = resolver.resolve(URLMaker.self)!
        return VideoRecorderImpl(urlMaker: urlMaker.backCamera)
      }
      .inObjectScope(.container)
  }

  func registerAudioRecorder() {
    self
      .register(AudioRecorder.self) { resolver in
        let urlMaker = resolver.resolve(URLMaker.self)!
        return AudioRecorderImpl(urlMaker: urlMaker.microphone)
      }
      .inObjectScope(.container)
  }

  func registerService() {
    register(CameraKitService.self) { resolver in
      let sessionConfigurator = resolver.resolve(SessionConfigurator.self, name: Self.internalSessionConfigurator)!
      let monitor = resolver.resolve(SessionMonitor.self, name: Self.internalSessionMonitor)!
      let frontCameraRecorder = resolver.resolve(VideoRecorder.self, name: Self.frontCameraRecorder)!
      let backCameraRecorder = resolver.resolve(VideoRecorder.self, name: Self.backCameraRecorder)!
      let audioRecorder = resolver.resolve(AudioRecorder.self)!
      return CameraKitServiceImpl(
        sessionConfigurator: sessionConfigurator,
        monitor: monitor,
        frontCameraRecorder: frontCameraRecorder,
        backCameraRecorder: backCameraRecorder,
        audioRecorder: audioRecorder
      )
    }
    .implements(SessionConfigurator.self, SessionPlayer.self, SessionMonitor.self)
    .inObjectScope(.container)
  }
}
