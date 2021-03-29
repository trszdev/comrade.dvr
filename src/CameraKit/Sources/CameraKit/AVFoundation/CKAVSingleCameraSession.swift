import AVFoundation
import Combine

enum CKAVSessionError: Error {
  case cantAddDevice
  case cantConnectDevice
  case cantConfigureDevice(inner: Error)
}

extension CKAVSessionError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .cantAddDevice:
      return "Can't add device"
    case let .cantConfigureDevice(inner):
      return "Can't configure device (\(inner.localizedDescription))"
    case .cantConnectDevice:
      return "Can't connect device"
    }
  }
}

final class CKAVSingleCameraSession: NSObject, CKSession {
  struct Builder {
    let mapper: CKAVConfigurationMapper

    func makeSession(configuration: CKConfiguration) -> CKAVSingleCameraSession {
      CKAVSingleCameraSession(configuration: configuration, mapper: mapper)
    }
  }

  init(configuration: CKConfiguration, mapper: CKAVConfigurationMapper) {
    self.configuration = configuration
    self.mapper = mapper
  }

  private(set) var cameras: [CKDeviceID: CKCameraDevice] = [:]
  private(set) var microphone: CKMicrophoneDevice?
  var pressureLevel: CKPressureLevel {
    let devices: [AVCaptureDevice] = session.connections.compactMap { connection in
      let input = connection.inputPorts.first?.input
      let deviceInput = input.flatMap { $0 as? AVCaptureDeviceInput }
      return deviceInput?.device
    }
    return devices.map(\.ckPressureLevel).max() ?? .nominal
  }
  private(set) var session = AVCaptureSession()
  let configuration: CKConfiguration
  let mapper: CKAVConfigurationMapper
  var plugins: [CKSessionPlugin] = []
  var camera: CKCameraDevice? {
    cameras.values.first
  }

  private(set) var isRunning: Bool = false

  func start() throws {
    session.stopRunning()
    session = AVCaptureSession()
    session.startRunning()
    if let camera = configuration.cameras.values.first {
      try tryAddCamera(camera: camera)
    }
    if let microphone = configuration.microphone {
      tryAddMicrophone(microphone: microphone)
    }
    session.commitConfiguration()
    session.startRunning()
    for plugin in plugins {
      plugin.didStart(session: self)
    }
  }

  private func tryAddCamera(camera: CKDevice<CKCameraConfiguration>) throws {
    let output = AVCaptureVideoDataOutput()
    output.setSampleBufferDelegate(self, queue: .global(qos: .userInteractive))
    guard let avDevice = mapper.avCaptureDevice(camera.key),
      let avFormat = mapper.avFormat(camera.key),
      let input = try? AVCaptureDeviceInput(device: avDevice),
      session.canAddInput(input),
      session.canAddOutput(output)
    else {
      throw CKAVSessionError.cantAddDevice
    }
    session.addInputWithNoConnections(input)
    session.addOutputWithNoConnections(output)
    let previewView = AVPreviewView()
    previewView.videoPreviewLayer.setSessionWithNoConnection(session)
    let ports = input.ports(for: .video, sourceDeviceType: avDevice.deviceType, sourceDevicePosition: avDevice.position)
    guard !ports.isEmpty else {
      throw CKAVSessionError.cantConnectDevice
    }
    let connection = AVCaptureConnection(inputPorts: ports, output: output)
    let previewConnection = AVCaptureConnection(inputPort: ports[0], videoPreviewLayer: previewView.videoPreviewLayer)
    guard session.canAddConnection(connection), session.canAddConnection(previewConnection) else {
      throw CKAVSessionError.cantConnectDevice
    }
    session.addConnection(connection)
    session.addConnection(previewConnection)
    do {
      try avDevice.lockForConfiguration()
    } catch {
      throw CKAVSessionError.cantConfigureDevice(inner: error)
    }
    for connection in [connection, previewConnection] {
      connection.videoOrientation = camera.configuration.orientation.avOrientation
      connection.preferredVideoStabilizationMode = camera.configuration.stabilizationMode.avStabilizationMode
    }
    avDevice.activeFormat = avFormat
    avDevice.videoZoomFactor = CGFloat(camera.configuration.zoom)
    avDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(camera.configuration.fps))
    avDevice.activeVideoMaxFrameDuration = avDevice.activeVideoMinFrameDuration
    avDevice.unlockForConfiguration()
    previewView.videoPreviewLayer.videoGravity = camera.configuration.videoGravity.avVideoGravity
    let ckPreviewView = CKCameraPreviewView(previewView)
    cameras[camera.id] = CKAVCameraDevice(device: camera, previewView: ckPreviewView)
  }

  private func tryAddMicrophone(microphone: CKDevice<CKMicrophoneConfiguration>) {
    let output = AVCaptureAudioDataOutput()
    output.setSampleBufferDelegate(self, queue: .global(qos: .userInteractive))
  }

  private func stop() {
    for plugin in plugins {
      plugin.didStop(session: self)
    }
  }
}

extension CKAVSingleCameraSession: AVCaptureVideoDataOutputSampleBufferDelegate,
  AVCaptureAudioDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let input = connection.inputPorts.first?.input,
      let deviceInput = input as? AVCaptureDeviceInput,
      let id = mapper.id(deviceInput.device)
    else {
      return
    }
    if let camera = configuration.cameras[id.deviceId] {
      // print(">>> capture camera \(id)")
    } else if let microphone = configuration.microphone, microphone.id == id.deviceId {
      // print(">>> microphone \(id)")
    }
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didDrop sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    // print("123123")
  }
}

extension AVCaptureDevice {
  var ckPressureLevel: CKPressureLevel {
    .nominal
  }
}
