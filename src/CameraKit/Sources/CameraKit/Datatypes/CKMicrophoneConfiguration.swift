import Foundation

public struct CKMicrophoneConfiguration: Identifiable, Hashable, Codable {
  public let id: CKDeviceConfigurationID
  public let orientation: CKOrientation
  public let location: CKDeviceLocation
  public let polarPattern: CKPolarPattern
  public let duckOthers: Bool
  public let useSpeaker: Bool
  public let useBluetoothCompatibilityMode: Bool
  public let audioQuality: CKQuality

  public init(
    orientation: CKOrientation,
    location: CKDeviceLocation,
    polarPattern: CKPolarPattern,
    duckOthers: Bool,
    useSpeaker: Bool,
    useBluetoothCompatibilityMode: Bool,
    audioQuality: CKQuality
  ) {
    self.id = CKDeviceConfigurationID(value: UUID().uuidString)
    self.orientation = orientation
    self.location = location
    self.polarPattern = polarPattern
    self.duckOthers = duckOthers
    self.useSpeaker = useSpeaker
    self.useBluetoothCompatibilityMode = useBluetoothCompatibilityMode
    self.audioQuality = audioQuality
  }

  init(
    id: CKDeviceConfigurationID,
    orientation: CKOrientation,
    location: CKDeviceLocation,
    polarPattern: CKPolarPattern,
    duckOthers: Bool,
    useSpeaker: Bool,
    useBluetoothCompatibilityMode: Bool,
    audioQuality: CKQuality
  ) {
    self.id = id
    self.orientation = orientation
    self.location = location
    self.polarPattern = polarPattern
    self.duckOthers = duckOthers
    self.useSpeaker = useSpeaker
    self.useBluetoothCompatibilityMode = useBluetoothCompatibilityMode
    self.audioQuality = audioQuality
  }
}
