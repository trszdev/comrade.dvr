import AVFoundation
import Combine
import Foundation

final class CKAVCameraSession: NSObject, CKSession, CKSessionPublisherProvider {
  struct Builder {
    let mapper: CKAVConfigurationMapper
    let recorderBuilder: CKAVCameraRecorderBuilder

    func makeSession(configuration: CKConfiguration, sessionPublisher: CKSessionPublisher) -> CKAVCameraSession {
      CKAVCameraSession(
        configuration: configuration,
        mapper: mapper,
        recorderBuilder: recorderBuilder,
        sessionPublisher: sessionPublisher
      )
    }
  }

  init(
    configuration: CKConfiguration,
    mapper: CKAVConfigurationMapper,
    recorderBuilder: CKAVCameraRecorderBuilder,
    sessionPublisher: CKSessionPublisher
  ) {
    self.configuration = configuration
    self.mapper = mapper
    self.recorderBuilder = recorderBuilder
    self.sessionPublisher = sessionPublisher
  }

  private(set) var cameras = [CKDeviceID: CKCameraDevice]()
  var microphone: CKMicrophoneDevice? { nil }
  let startupInfo = CKSessionStartupInfo()
  let configuration: CKConfiguration
  let sessionPublisher: CKSessionPublisher

  func requestMediaChunk() {
    for recorder in recorders {
      recorder.requestMediaChunk()
    }
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
    session = configuration.cameras.count < 2 ? AVCaptureSession() : AVCaptureMultiCamSession()
    session.beginConfiguration()
    for camera in configuration.cameras.values {
      try tryAddCamera(camera: camera)
    }
    session.commitConfiguration()
    session.startRunning()
    if let multicamSession = session as? AVCaptureMultiCamSession {
      if multicamSession.hardwareCost >= 1 {
        throw CKAVCameraSessionError.hardwareCostExceeded
      }
      if multicamSession.systemPressureCost >= 1 {
        throw CKAVCameraSessionError.systemPressureExceeded
      }
    }
  }

  @objc private func didReceiveRuntimeError(notification: Notification) {
    guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
      assert(false, "Unknown notification")
      return
    }
    switch error.code {
    case .sessionHardwareCostOverage:
      sessionPublisher.outputPublisher.send(completion: .failure(CKAVCameraSessionError.hardwareCostExceeded))
    default:
      sessionPublisher.outputPublisher.send(completion: .failure(CKAVCameraSessionError.runtimeError(inner: error)))
    }
  }

  private func tryAddCamera(camera: CKDevice<CKCameraConfiguration>) throws {
    guard let avDevice = mapper.avCaptureDevice(camera.key),
      let avFormat = mapper.avFormat(camera.key),
      let input = try? AVCaptureDeviceInput(device: avDevice)
    else {
      throw CKAVCameraSessionError.cantAddDevice
    }
    let recorder = recorderBuilder.makeRecorder(sessionPublisher: sessionPublisher)
    let output = AVCaptureVideoDataOutput()
    output.setSampleBufferDelegate(recorder, queue: videoQueue)
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
    recorders.append(recorder)
    let ckPreviewView = CKCameraPreviewView(configurator.previewView)
    cameras[camera.id] = CKAVCameraDevice(device: camera, previewView: ckPreviewView)
    observations.append(avDevice.observe(\.systemPressureState, options: .new) { [weak self] device, _ in
      self?.sessionPublisher.pressureLevelPublisher.send(device.ckPressureLevel)
    })
  }

  private var observations = [NSKeyValueObservation]()
  private lazy var videoQueue = DispatchQueue(label: "\(Self.self)[\(startupInfo.id.uuid)]", qos: .userInteractive)
  private let mapper: CKAVConfigurationMapper
  private var session = AVCaptureSession()
  private let recorderBuilder: CKAVCameraRecorderBuilder
  private var recorders = [CKAVCameraRecorder]()
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
    connection.videoOrientation = configuration.orientation.avOrientation
    previewConnection.videoOrientation = configuration.orientation.avOrientation
    previewConnection.preferredVideoStabilizationMode = configuration.stabilizationMode.avStabilizationMode
    connection.preferredVideoStabilizationMode = configuration.stabilizationMode.avStabilizationMode
    guard session.canAddConnection(previewConnection), session.canAddConnection(connection) else {
      throw CKAVCameraSessionError.cantConnectDevice
    }
    session.addConnection(connection)
    session.addConnection(previewConnection)
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
