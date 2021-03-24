struct CKAVCameraDevice: CKCameraDevice {
  let device: CKDevice<CKCameraConfiguration>
  let previewView: CKCameraPreviewView
}
