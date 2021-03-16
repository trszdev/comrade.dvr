public protocol CKCameraDevice {
  var device: CKDevice<CKCameraConfiguration> { get }
  var previewView: CKCameraPreviewView { get }
}
