import AVFoundation
import Combine

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
  private(set) var pressureLevel: CKPressureLevel = .nominal
  private(set) var session = AVCaptureSession()
  let configuration: CKConfiguration
  let mapper: CKAVConfigurationMapper
  var plugins: [CKSessionPlugin] = []
  var camera: CKCameraDevice? {
    cameras.values.first
  }

  var isRunning: Bool {
    get {
      isRunningInternal
    }
    set {
      isRunningInternal = newValue
      if isRunningInternal {
        start()
      } else {
        stop()
      }
    }
  }

  private var isRunningInternal = false

  private func tryAddCamera(camera: CKDevice<CKCameraConfiguration>) {
    let output = AVCaptureVideoDataOutput()
    output.setSampleBufferDelegate(self, queue: .global(qos: .userInteractive))
    guard tryAddInputOutput(for: camera, output: output) else { return }
    let previewView = AVPreviewView()
    previewView.videoPreviewLayer.session = session
    previewView.videoPreviewLayer.videoGravity = camera.configuration.videoGravity.avVideoGravity
    let ckPreviewView = CKCameraPreviewView(previewView)
    cameras[camera.id] = CKAVCameraDevice(device: camera, previewView: ckPreviewView)
  }

  private func tryAddMicrophone(microphone: CKDevice<CKMicrophoneConfiguration>) {
    let output = AVCaptureAudioDataOutput()
    output.setSampleBufferDelegate(self, queue: .global(qos: .userInteractive))
    tryAddInputOutput(for: microphone, output: output)
  }

  @discardableResult private func tryAddInputOutput<T: Identifiable>(
    for device: CKDevice<T>,
    output: AVCaptureOutput
  ) -> Bool where T.ID == CKDeviceConfigurationID {
    guard let avDevice = mapper.avCaptureDevice(device.id, device.configuration.id),
      let input = try? AVCaptureDeviceInput(device: avDevice),
      session.canAddInput(input),
      session.canAddOutput(output)
    else {
      return false
    }
    session.addInput(input)
    session.addOutput(output)
    return true
  }

  private func start() {
    session.stopRunning()
    session = AVCaptureSession()
    if let camera = configuration.cameras.values.first {
      tryAddCamera(camera: camera)
    }
    if let microphone = configuration.microphone {
      tryAddMicrophone(microphone: microphone)
    }
    session.startRunning()
    for plugin in plugins {
      plugin.didStart(session: self)
    }
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
    let input = connection.inputPorts.first?.input
    print(">>> captureOutput \(input)")
  }
}
