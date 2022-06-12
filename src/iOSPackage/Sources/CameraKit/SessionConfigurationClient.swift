import Device
import AVFoundation

struct SessionConfigurationClient {
  var updateFrontCamera: async throws (CameraConfiguration?) -> Void
  var updateBackCamera: async throws (CameraConfiguration?) -> Void
  var updateMicrophone: async throws (M icrophoneConfiguration?) -> Void
  var currentSession: () -> AVCaptureSession?
}
