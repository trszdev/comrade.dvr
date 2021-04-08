import UIKit
import AVFoundation
import Combine
import CameraKit
import SwiftUI

final class MainViewController: UIViewController {
  private let responsivenessView: UISlider = {
    let result = UISlider()
    result.translatesAutoresizingMaskIntoConstraints = false
    result.addConstraint(result.widthAnchor.constraint(equalToConstant: 200))
    return result
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    printCurrentTime()
    view.addSubview(responsivenessView)
    NSLayoutConstraint.activate([
      responsivenessView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      responsivenessView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
    DispatchQueue.main.asyncAfter(deadline: .now()) {
      CKAVManager.shared.sessionMakerPublisher
        .receive(on: DispatchQueue.main)
        .map { [weak self] sessionMaker in
          self?.startSession(sessionMaker: sessionMaker)
        }
        .sinkAndStore()
    }
  }

  private func addSessionTemplates(
    sessionMaker: CKSessionMaker,
    alertVc: UIAlertController,
    backCameraId: CKDeviceID?,
    frontCameraId: CKDeviceID?,
    microphoneId: CKDeviceID?
  ) {
    if let backCameraId = backCameraId {
      addAction(
        alertVc: alertVc,
        title: microphoneId == nil ? "Back only" : "Back + mic",
        sessionMaker: sessionMaker,
        cameraIds: [backCameraId],
        microphoneId: microphoneId
      )
    }
    if let frontCameraId = frontCameraId {
      addAction(
        alertVc: alertVc,
        title: microphoneId == nil ? "Front only" : "Front + mic",
        sessionMaker: sessionMaker,
        cameraIds: [frontCameraId],
        microphoneId: microphoneId
      )
    }
    if let backCameraId = backCameraId, let frontCameraId = frontCameraId {
      addAction(
        alertVc: alertVc,
        title: microphoneId == nil ? "Back + front" : "Back + front + mic",
        sessionMaker: sessionMaker,
        cameraIds: [backCameraId, frontCameraId],
        microphoneId: microphoneId
      )
    }
  }

  private func startSession(sessionMaker: CKSessionMaker) {
    let backCameraId = sessionMaker.adjustableConfiguration.camera(.back)?.id
    let frontCameraId = sessionMaker.adjustableConfiguration.camera(.front)?.id
    let microphoneId = sessionMaker.adjustableConfiguration.microphone?.id
    print("Available configuration:")
    dump(sessionMaker.adjustableConfiguration.ui)
    guard backCameraId != nil, frontCameraId != nil else {
      alert(message: "No default cameras found")
      return
    }
    let alertVc = UIAlertController(title: "Choose preset", message: nil, preferredStyle: .alert)
    addSessionTemplates(
      sessionMaker: sessionMaker,
      alertVc: alertVc,
      backCameraId: backCameraId,
      frontCameraId: frontCameraId,
      microphoneId: microphoneId
    )
    addSessionTemplates(
      sessionMaker: sessionMaker,
      alertVc: alertVc,
      backCameraId: backCameraId,
      frontCameraId: frontCameraId,
      microphoneId: nil
    )
    present(alertVc, animated: true, completion: nil)
  }

  private func addAction(
    alertVc: UIAlertController,
    title: String,
    sessionMaker: CKSessionMaker,
    cameraIds: [CKDeviceID],
    microphoneId: CKDeviceID?
  ) {
    let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
      guard let self = self else { return }
      do {
        let session = try self.makeSession(sessionMaker: sessionMaker, cameraIds: cameraIds, microphoneId: microphoneId)
        self.alert(title: "Session info", message: String(describing: session.configuration)) {
          let hostingVc = UIHostingController(rootView: CameraKitView(session: session))
          hostingVc.view.backgroundColor = .black
          printCurrentTime()
          self.present(hostingVc, animated: true, completion: nil)
        }
      } catch {
        self.alert(message: error.localizedDescription)
      }
    }
    alertVc.addAction(action)
  }

  private func alert(title: String = "Error", message: String, afterOk: (() -> Void)? = nil) {
    let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if let afterOk = afterOk {
      alertVc.addAction(UIAlertAction(title: "OK", style: .default) { _ in afterOk() })
    }
    present(alertVc, animated: true, completion: nil)
  }

  private func makeSession(
    sessionMaker: CKSessionMaker,
    cameraIds: [CKDeviceID],
    microphoneId: CKDeviceID?
  ) throws -> CKSession {
    let cameras = cameraIds.map { CKDevice(id: $0, configuration: someConfiguration)}
    let microphone = microphoneId.flatMap { CKDevice(id: $0, configuration: someMicConf) }
    let configuration = CKConfiguration(cameras: Set(cameras), microphone: microphone)
    return try sessionMaker.makeSession(configuration: configuration)
  }

  private var someConfiguration = CKCameraConfiguration(
    size: CKSize(width: 1920, height: 1080),
    zoom: 1,
    fps: 60,
    fieldOfView: 107,
    orientation: .portrait,
    autoFocus: .phaseDetection,
    stabilizationMode: .auto,
    videoGravity: .resizeAspect
  )

  private var someMicConf = CKMicrophoneConfiguration(
    orientation: .portrait,
    location: .unspecified,
    polarPattern: .unspecified,
    duckOthers: false,
    useSpeaker: false,
    useBluetoothCompatibilityMode: false,
    audioQuality: .min
  )
}
//
// final class CameraViewController: UIViewController {
//  var session: AVCaptureSession!
//  let debugLabel = UILabel()
//  let nextFormatButton = UIButton()
//  let prevFormatButton = UIButton()
//  var previewLayer: AVCaptureVideoPreviewLayer!
//  var previewLayerOuter: AVCaptureVideoPreviewLayer!
//  var cancellables = Set<AnyCancellable>()
//
//  override func viewWillLayoutSubviews() {
//    super.viewWillLayoutSubviews()
//    let width = view.frame.width
//    let height = view.frame.height
//    let padding = CGFloat(80)
//    nextFormatButton.frame = CGRect(x: padding, y: padding, width: padding, height: padding)
//    prevFormatButton.frame = CGRect(x: width - padding - padding, y: padding, width: padding, height: padding)
//    debugLabel.frame = CGRect(x: 0, y: height - 300, width: width, height: 250)
//    previewLayer.connection?.videoOrientation = .portrait
//    previewLayer.frame = view.bounds
//    let names: [Notification.Name] = [
//      .AVCaptureSessionRuntimeError,
//      .AVCaptureDeviceWasConnected,
//      .AVCaptureDeviceWasDisconnected,
//      .AVCaptureSessionInterruptionEnded,
//      .AVCaptureSessionDidStopRunning,
//      .AVCaptureSessionDidStartRunning,
//      .AVCaptureDeviceSubjectAreaDidChange,
//      // .AVCaptureInputPortFormatDescriptionDidChange,
//    ]
//    for name in names {
//      NotificationCenter.default.publisher(for: name)
//        .sink(receiveValue: receiveNotification(notification:))
//        .store(in: &cancellables)
//    }
//    NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
//      .sink(receiveValue: rotated)
//      .store(in: &cancellables)
//  }
//
//  func receiveNotification(notification: Notification) {
//    switch notification.name {
//    case .AVCaptureSessionDidStopRunning:
//      print(">>> Session unloaded")
//      // setupNewRandomCamera()
//    case .AVCaptureSessionRuntimeError:
//      print(">>> Runtime error (\(notification.debugDescription), next camera preset...")
//      // unloadCameraAndSetupNewOne()
//    default:
//      print(notification)
//    }
//  }
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    nextFormatButton.addTarget(self, action: #selector(nextFormat), for: .touchUpInside)
//    prevFormatButton.addTarget(self, action: #selector(unloadCameraAndSetupNewOne), for: .touchUpInside)
//    nextFormatButton.setBackgroundColor(color: .red, forState: .normal)
//    prevFormatButton.setBackgroundColor(color: .blue, forState: .normal)
//    prevFormatButton.setTitle("Next device", for: .normal)
//    debugLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
//    debugLabel.lineBreakMode = .byWordWrapping
//    debugLabel.numberOfLines = 0
//    nextFormatButton.titleLabel?.adjustsFontSizeToFitWidth = true
//    view.addSubview(nextFormatButton)
//    view.addSubview(prevFormatButton)
//    view.addSubview(debugLabel)
//    AVCaptureDevice.requestAccess(for: .audio) { _ in
//      AVCaptureDevice.requestAccess(for: .video) { _ in
//        self.setupSession()
//      }
//    }
//  }
//
//  @objc func restartSession() {
//    session.stopRunning()
//    setupSession()
//  }
//
//  func setupNewRandomCamera() {
//    guard let session = session, session.connections.isEmpty else {
//      print(">>> Session already has connections!")
//      return
//    }
//    try? FileManager.default.removeItem(at: Self.videoUrl)
//    print(">>> Switching to new camera")
//    let cameras = self.cameras()
//    maxDevices = cameras.count
//    let randomDevice = cameras[deviceCounter]
//    formatCounter = 0
//    formatReady = 0
//    // describe(device: randomDevice)
//    let input = try! AVCaptureDeviceInput(device: randomDevice)
//    session.addInputWithNoConnections(input)
//    nextFormat()
//    deviceCounter = (deviceCounter + 1) % maxDevices
//    session.addConnection(AVCaptureConnection(inputPort: input.ports.first!, videoPreviewLayer: previewLayer))
//    let output = AVCaptureVideoDataOutput()
//    output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
//    session.addOutput(output)
//    videoWriter = try! AVAssetWriter(outputURL: CameraViewController.videoUrl, fileType: .mov)
//    videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
//      AVVideoCodecKey: AVVideoCodecType.h264,
//      AVVideoWidthKey: randomDevice.activeFormat.size.0,
//      AVVideoHeightKey: randomDevice.activeFormat.size.1,
//      AVVideoCompressionPropertiesKey: [
//        AVVideoAverageBitRateKey: 2300000,
//      ],
//    ])
//    videoWriterInput?.expectsMediaDataInRealTime = true
//    videoWriter.add(videoWriterInput!)
//    //    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
//    //      self.videoWriterInput?.markAsFinished()
//    //      self.videoWriterInput = nil
//    //      // self.videoWriter.endSession(atSourceTime: CMTime(seconds: 10, preferredTimescale: 1))
//    //      self.videoWriter.finishWriting {
//    //        DispatchQueue.main.async {
//    //          let player = AVPlayer(url: CameraViewController.videoUrl)
//    //          let playerController = AVPlayerViewController()
//    //          playerController.player = player
//    //          self.present(playerController, animated: true) {
//    //            player.play()
//    //          }
//    //        }
//    //
//    //      }
//    //    }
//    allFormats()
//    session.startRunning()
//  }
//
//  func allFormats() {
//    let allDevices = cameras().filter { $0.position == .back }
//    var formats = [String: [(AVCaptureDevice, AVCaptureDevice.Format)]]()
//    for camera in allDevices {
//      for format in camera.formats {
//        let key = "\(format.size.0)x\(format.size.1)"
//        if formats[key] == nil {
//          formats[key] = []
//        }
//        formats[key]?.append((camera, format))
//      }
//    }
//    print(123)
//  }
//  var deviceCounter = 0
//  var maxDevices = 0
//  var formatCounter = 0
//  var maxFormats = 0
//
//  @objc func nextFormat() {
//    let input = session.inputs[0] as! AVCaptureDeviceInput
//    let device = input.device
//    try! device.lockForConfiguration()
//    let formats = device.formats.sorted { $0.sizeScalar > $1.sizeScalar }
//    maxFormats = formats.count
//    let newFormat = device.formats[formatCounter]
//    device.activeFormat = newFormat
//    let conf = newFormat.videoSupportedFrameRateRanges[0]
//    device.activeVideoMaxFrameDuration = conf.minFrameDuration
//    device.activeVideoMinFrameDuration = conf.minFrameDuration
//    device.unlockForConfiguration()
//    describe(device: device)
//    formatCounter = (formatCounter + 1) % maxFormats
//  }
//
//  var videoWriter: AVAssetWriter!
//  var videoWriterInput: AVAssetWriterInput?
//  static var videoUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    .appendingPathComponent("movie.mov")
//
//  @objc func prevFormat() {
//
//  }
//
//  func cameras() -> [AVCaptureDevice] {
//    let session = AVCaptureDevice.DiscoverySession(
//      deviceTypes: cameraDeviceTypes,
//      mediaType: .video,
//      position: .unspecified
//    )
//    return session.devices
//  }
//
//  var formatReady = 0
// }
//
// extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//  func captureOutput(
//    _ output: AVCaptureOutput,
//    didOutput sampleBuffer: CMSampleBuffer,
//    from connection: AVCaptureConnection
//  ) {
//    print(sampleBuffer.numSamples)
//    if videoWriter.status == .unknown {
//      let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
//      videoWriter.startWriting()
//      videoWriter.startSession(atSourceTime: startTime)
//    }
//    if let input = videoWriterInput, input.isReadyForMoreMediaData {
//      input.append(sampleBuffer)
//    }
//  }
// }
