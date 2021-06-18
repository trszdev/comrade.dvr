import CameraKit

enum DeviceConfiguration: Codable {
  struct DecodingError: Error {
  }

  case camera(configuration: CKCameraConfiguration)
  case microphone(configuration: CKMicrophoneConfiguration)

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let configuration = try? values.decode(CKCameraConfiguration.self, forKey: .cameraConfiguration) {
      self = .camera(configuration: configuration)
      return
    }
    if let configuration = try? values.decode(CKMicrophoneConfiguration.self, forKey: .microphoneConfiguration) {
      self = .microphone(configuration: configuration)
      return
    }
    throw DecodingError()
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .camera(configuration):
      try container.encode(configuration, forKey: .cameraConfiguration)
    case let .microphone(configuration):
      try container.encode(configuration, forKey: .microphoneConfiguration)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case cameraConfiguration
    case microphoneConfiguration
  }
}
