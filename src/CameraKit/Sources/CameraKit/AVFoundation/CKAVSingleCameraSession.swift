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
    let output = AVCaptureVideoDataOutput()
    output.setSampleBufferDelegate(recorder, queue: videoQueue)
    try recorder.setup(output: output, camera: camera)
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
    try recorder.setup(output: output, camera: camera)
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

  private lazy var videoQueue = DispatchQueue(label: "\(Self.self)[\(startupInfo.id.uuid)]", qos: .userInteractive)
  private let mapper: CKAVConfigurationMapper
  private var session = AVCaptureSession()
  private let recorder: CKAVCameraRecorder
}
