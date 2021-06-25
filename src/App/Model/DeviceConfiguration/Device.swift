import CameraKit

enum Device: Codable, Identifiable, Equatable {
  var id: CKDeviceID {
    switch self {
    case let .camera(device):
      return device.id
    case let .microphone(device):
      return device.id
    }
  }

  struct DecodingError: Error {
  }

  case camera(device: CameraDevice)
  case microphone(device: MicrophoneDevice)

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let device = try? values.decode(CameraDevice.self, forKey: .camera) {
      self = .camera(device: device)
      return
    }
    if let device = try? values.decode(MicrophoneDevice.self, forKey: .microphone) {
      self = .microphone(device: device)
      return
    }
    throw DecodingError()
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .camera(configuration):
      try container.encode(configuration, forKey: .camera)
    case let .microphone(configuration):
      try container.encode(configuration, forKey: .microphone)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case camera
    case microphone
  }
}
