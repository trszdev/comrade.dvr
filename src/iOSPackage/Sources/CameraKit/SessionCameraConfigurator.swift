import AVFoundation
import Device

struct SessionCameraConfigurator {
  let session: AVCaptureSession
  let deviceWithFormat: DeviceWithFormat
  let configuration: CameraConfiguration
  let input: AVCaptureDeviceInput
  let output: AVCaptureVideoDataOutput
  let previewView: PreviewView

  func configurePreviewView() {
    previewView.videoPreviewLayer.setSessionWithNoConnection(session)
//    previewView.videoPreviewLayer.videoGravity = configuration.videoGravity.avVideoGravity
//    switch configuration.orientation {
//    case .portrait:
//      previewView.transform = .identity
//    case .portraitUpsideDown:
//      previewView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
//    case .landscapeLeft:
//      previewView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
//    case .landscapeRight:
//      previewView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
//    }
  }

  func addInputOutput() throws {
    guard session.canAddInput(input), session.canAddOutput(output) else {
      throw SessionCameraConfiguratorError.cantAddDevice
    }
    session.addInputWithNoConnections(input)
    session.addOutputWithNoConnections(output)
  }

  func addConnections() throws {
    let device = deviceWithFormat.device
    let ports = input.ports(for: .video, sourceDeviceType: device.deviceType, sourceDevicePosition: device.position)
    guard !ports.isEmpty else {
      throw SessionCameraConfiguratorError.cantConnectDevice
    }
    let connection = AVCaptureConnection(inputPorts: ports, output: output)
    let previewConnection = AVCaptureConnection(inputPort: ports[0], videoPreviewLayer: previewView.videoPreviewLayer)
//    connection.videoOrientation = configuration.orientation.avOrientation
//    previewConnection.videoOrientation = configuration.orientation.avOrientation
//    previewConnection.preferredVideoStabilizationMode = configuration.stabilizationMode.avStabilizationMode
//    connection.preferredVideoStabilizationMode = configuration.stabilizationMode.avStabilizationMode
    guard session.canAddConnection(previewConnection), session.canAddConnection(connection) else {
      throw SessionCameraConfiguratorError.cantConnectDevice
    }
    session.addConnection(connection)
    session.addConnection(previewConnection)
  }

  func configureDevice() throws {
    let device = deviceWithFormat.device
    do {
      try device.lockForConfiguration()
    } catch {
      throw SessionCameraConfiguratorError.cantConfigureDevice(innerError: error)
    }
    device.activeFormat = deviceWithFormat.format
    device.videoZoomFactor = CGFloat(configuration.zoom)
    device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(configuration.fps))
    device.activeVideoMaxFrameDuration = device.activeVideoMinFrameDuration
    device.unlockForConfiguration()
  }
}

enum SessionCameraConfiguratorError: Error {
  case cantAddDevice
  case cantConnectDevice
  case cantConfigureDevice(innerError: Error)
}
