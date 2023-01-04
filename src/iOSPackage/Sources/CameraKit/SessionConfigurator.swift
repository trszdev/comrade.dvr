import AVFoundation
import Device
import Util

public protocol SessionConfigurator {
  func updateFrontCamera(_ configuration: CameraConfiguration?) async throws
  func updateBackCamera(_ configuration: CameraConfiguration?) async throws
  func updateMicrophone(_ configuration: MicrophoneConfiguration?) async throws
}

public struct SessionConfiguratorStub: SessionConfigurator {
  public init() {}

  public func updateFrontCamera(_ configuration: CameraConfiguration?) async throws {
    try await Task.sleep(.seconds(5))
    if Bool.random() {
      throw SessionConfiguratorError.frontCamera(\.quality)
    }
  }

  public func updateBackCamera(_ configuration: CameraConfiguration?) async throws {
  }

  public func updateMicrophone(_ configuration: MicrophoneConfiguration?) async throws {
    try await Task.sleep(.seconds(10))
    throw SessionConfiguratorError.microphone(\.polarPattern)
  }
}
