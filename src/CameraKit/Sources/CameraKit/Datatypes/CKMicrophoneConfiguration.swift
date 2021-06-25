import Foundation

public struct CKMicrophoneConfiguration: Identifiable, Hashable, Codable {
  public var id: CKDeviceConfigurationID
  public var orientation: CKOrientation
  public var location: CKDeviceLocation
  public var polarPattern: CKPolarPattern
  public var duckOthers: Bool
  public var useSpeaker: Bool
  public var useBluetoothCompatibilityMode: Bool
  public var audioQuality: CKQuality

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
