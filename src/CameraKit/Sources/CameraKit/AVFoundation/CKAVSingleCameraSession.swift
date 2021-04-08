import AVFoundation
import Combine
import Foundation

enum CKAVCameraSessionError: Error {
  case cantAddDevice
  case cantConnectDevice
  case cantConfigureDevice(inner: Error)
}

extension CKAVCameraSessionError: LocalizedError {
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
  let startupInfo = CKSessionStartupInfo()

  func requestMediaChunk() {
  }

  struct Builder {
    let mapper: CKAVConfigurationMapper

    func makeSession(configuration: CKConfiguration) -> CKAVSingleCameraSession {
      CKAVSingleCameraSession(configuration: configuration, mapper: mapper)
    }
  }

  init(configuration: CKConfiguration, mapper: CKAVConfigurationMapper) {
    self.configuration = configuration
    self.mapper = mapper
    //    NotificationCenter.default.publisher(for: .AVCaptureSessionWasInterrupted)
    //      .sink(receiveValue: cameraCaptureWasInterrupted)
    //      .store(in: &cancellables)
    //    NotificationCenter.default.publisher(for: .AVCaptureSessionInterruptionEnded)
    //      .sink(receiveValue: cameraCaptureInterruptionEnded)
    //      .store(in: &cancellables)
  }

  weak var delegate: CKSessionDelegate?

  private(set) var cameras: [CKDeviceID: CKCameraDevice] = [:]

  var microphone: CKMicrophoneDevice? { nil }

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

  var camera: CKCameraDevice? {
    cameras.values.first
  }

  private(set) var isRunning: Bool = false

  func start() throws {
    session.stopRunning()
    session = AVCaptureSession()
    session.beginConfiguration()
    if let camera = configuration.cameras.values.first {
      try tryAddCamera(camera: camera)
    }
    session.commitConfiguration()
    session.startRunning()
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
      throw CKAVCameraSessionError.cantAddDevice
    }
    session.addInputWithNoConnections(input)
    session.addOutputWithNoConnections(output)
    let previewView = AVPreviewView()
    previewView.videoPreviewLayer.setSessionWithNoConnection(session)
    let ports = input.ports(for: .video, sourceDeviceType: avDevice.deviceType, sourceDevicePosition: avDevice.position)
    guard !ports.isEmpty else {
      throw CKAVCameraSessionError.cantConnectDevice
    }
    let connection = AVCaptureConnection(inputPorts: ports, output: output)
    let previewConnection = AVCaptureConnection(inputPort: ports[0], videoPreviewLayer: previewView.videoPreviewLayer)
    guard session.canAddConnection(connection), session.canAddConnection(previewConnection) else {
      throw CKAVCameraSessionError.cantConnectDevice
    }
    session.addConnection(connection)
    session.addConnection(previewConnection)
    do {
      try avDevice.lockForConfiguration()
    } catch {
      throw CKAVCameraSessionError.cantConfigureDevice(inner: error)
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
}

extension CKAVSingleCameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let input = connection.inputPorts.first?.input,
      let deviceInput = input as? AVCaptureDeviceInput,
      let id = mapper.id(deviceInput.device)
    else {
      // print(1234)
      return
    }
    if let camera = configuration.cameras[id.deviceId] {
      // print(">>> capture camera \(id)")
    // } else if let microphone = configuration.microphone, microphone.id == id.deviceId {
      // print(">>> microphone \(id)")
    } else {
      // print(123)
    }
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didDrop sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let input = connection.inputPorts.first?.input,
      let deviceInput = input as? AVCaptureDeviceInput,
      let id = mapper.id(deviceInput.device)
    else {
      return
    }
    // print(">>> Dropped: \(id)")
  }
}
