import AVFoundation
import Combine
import Foundation

final class CKAVSingleCameraSession: NSObject, CKSession {
  struct Builder {
    let mapper: CKAVConfigurationMapper
    let recorder: CKAVCameraRecorder

    func makeSession(configuration: CKConfiguration) -> CKAVSingleCameraSession {
      CKAVSingleCameraSession(configuration: configuration, mapper: mapper, recorder: recorder)
    }
  }

  init(configuration: CKConfiguration, mapper: CKAVConfigurationMapper, recorder: CKAVCameraRecorder) {
    self.configuration = configuration
    self.mapper = mapper
    self.recorder = recorder
  }

  weak var delegate: CKSessionDelegate? {
    didSet {
      recorder.sessionDelegate = delegate
    }
  }

  private(set) var cameras = [CKDeviceID: CKCameraDevice]()
  var microphone: CKMicrophoneDevice? { nil }
  let startupInfo = CKSessionStartupInfo()
  let configuration: CKConfiguration

  func requestMediaChunk() {
    recorder.requestMediaChunk()
  }

  var pressureLevel: CKPressureLevel {
    let devices: [AVCaptureDevice] = session.connections.compactMap { connection in
      let input = connection.inputPorts.first?.input
      let deviceInput = input.flatMap { $0 as? AVCaptureDeviceInput }
      return deviceInput?.device
    }
    return devices.map(\.ckPressureLevel).max() ?? .nominal
  }

  func start() throws {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didReceiveRuntimeError(notification:)),
      name: .AVCaptureSessionRuntimeError,
      object: nil
    )
    session.stopRunning()
    session = AVCaptureSession()
    session.beginConfiguration()
    if let camera = configuration.cameras.values.first {
      try tryAddCamera(camera: camera)
    }
    session.commitConfiguration()
    session.startRunning()
  }

  @objc private func didReceiveRuntimeError(notification: Notification) {
    guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
      assert(false, "Unknown notification")
      return
    }
    delegate?.sessionDidOutput(error: CKAVCameraSessionError.runtimeError(inner: error))
  }

  private func tryAddCamera(camera: CKDevice<CKCameraConfiguration>) throws {
    guard let avDevice = mapper.avCaptureDevice(camera.key),
      let avFormat = mapper.avFormat(camera.key),
      let input = try? AVCaptureDeviceInput(device: avDevice)
    else {
      throw CKAVCameraSessionError.cantAddDevice
    }
    let output = AVCaptureVideoDataOutput()
    output.setSampleBufferDelegate(recorder, queue: videoQueue)
    print(output.availableVideoPixelFormatNames)
    output.setPixelFormat(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
    let configurator = CKAVCameraConfigurator(
      session: session,
      avDevice: avDevice,
      avFormat: avFormat,
      configuration: camera.configuration,
      input: input,
      output: output
    )
    try configurator.addInputOutput()
    configurator.configurePreviewView()
    try configurator.addConnections()
    try configurator.configureDevice()
    try recorder.setup(output: output, camera: camera)
    let ckPreviewView = CKCameraPreviewView(configurator.previewView)
    cameras[camera.id] = CKAVCameraDevice(device: camera, previewView: ckPreviewView)
  }

  private lazy var videoQueue = DispatchQueue(label: "\(Self.self)[\(startupInfo.id.uuid)]", qos: .userInteractive)
  private let mapper: CKAVConfigurationMapper
  private var session = AVCaptureSession()
  private let recorder: CKAVCameraRecorder
}

private struct CKAVCameraConfigurator {
  let session: AVCaptureSession
  let avDevice: AVCaptureDevice
  let avFormat: AVCaptureDevice.Format
  let configuration: CKCameraConfiguration
  let input: AVCaptureDeviceInput
  let output: AVCaptureVideoDataOutput
  let previewView = AVPreviewView()

  func configurePreviewView() {
    previewView.videoPreviewLayer.setSessionWithNoConnection(session)
    previewView.videoPreviewLayer.videoGravity = configuration.videoGravity.avVideoGravity
    switch configuration.orientation {
    case .portrait:
      previewView.transform = .identity
    case .portraitUpsideDown:
      previewView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    case .landscapeLeft:
      previewView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
    case .landscapeRight:
      previewView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
    }
  }

  func addInputOutput() throws {
    guard session.canAddInput(input), session.canAddOutput(output) else {
      throw CKAVCameraSessionError.cantAddDevice
    }
    session.addInputWithNoConnections(input)
    session.addOutputWithNoConnections(output)
  }

  func addConnections() throws {
    let ports = input.ports(for: .video, sourceDeviceType: avDevice.deviceType, sourceDevicePosition: avDevice.position)
    guard !ports.isEmpty else {
      throw CKAVCameraSessionError.cantConnectDevice
    }
    let connection = AVCaptureConnection(inputPorts: ports, output: output)
    let previewConnection = AVCaptureConnection(inputPort: ports[0], videoPreviewLayer: previewView.videoPreviewLayer)
    let connections = [connection, previewConnection]
    for connection in connections {
      connection.videoOrientation = configuration.orientation.avOrientation
      connection.preferredVideoStabilizationMode = configuration.stabilizationMode.avStabilizationMode
    }
    guard connections.allSatisfy(session.canAddConnection) else {
      throw CKAVCameraSessionError.cantConnectDevice
    }
    for connection in connections {
      session.addConnection(connection)
    }
  }

  func configureDevice() throws {
    do {
      try avDevice.lockForConfiguration()
    } catch {
      throw CKAVCameraSessionError.cantConfigureDevice(inner: error)
    }
    avDevice.activeFormat = avFormat
    avDevice.videoZoomFactor = CGFloat(configuration.zoom)
    avDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(configuration.fps))
    avDevice.activeVideoMaxFrameDuration = avDevice.activeVideoMinFrameDuration
    avDevice.unlockForConfiguration()
  }
}
