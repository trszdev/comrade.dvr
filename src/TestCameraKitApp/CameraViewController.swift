import UIKit
import AVFoundation
import Combine
import AVKit

final class MainViewController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let cameraVc = CameraViewController()
    cameraVc.tabBarItem = UITabBarItem(tabBarSystemItem: .topRated, tag: 0)
    let second = UIViewController()
    second.view.backgroundColor = .red
    second.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
    setViewControllers([cameraVc, second], animated: false)
  }
}

final class CameraViewController: UIViewController {
  var session: AVCaptureSession!
  let debugLabel = UILabel()
  let nextFormatButton = UIButton()
  let prevFormatButton = UIButton()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var previewLayerOuter: AVCaptureVideoPreviewLayer!
  var cancellables = Set<AnyCancellable>()

  func rotated(notification: Notification) {
    switch UIDevice.current.orientation {
    case .landscapeLeft:
      previewLayer.connection?.videoOrientation = .landscapeRight
    case .landscapeRight:
      previewLayer.connection?.videoOrientation = .landscapeLeft
    case .portrait:
      previewLayer.connection?.videoOrientation = .portrait
    case .portraitUpsideDown:
      previewLayer.connection?.videoOrientation = .portraitUpsideDown
    default:
      break
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let width = view.frame.width
    let height = view.frame.height
    let padding = CGFloat(80)
    nextFormatButton.frame = CGRect(x: padding, y: padding, width: padding, height: padding)
    prevFormatButton.frame = CGRect(x: width - padding - padding, y: padding, width: padding, height: padding)
    debugLabel.frame = CGRect(x: 0, y: height - 300, width: width, height: 250)
    previewLayer.connection?.videoOrientation = .portrait
    previewLayer.frame = view.bounds
    let names: [Notification.Name] = [
      .AVCaptureSessionRuntimeError,
      .AVCaptureDeviceWasConnected,
      .AVCaptureDeviceWasDisconnected,
      .AVCaptureSessionInterruptionEnded,
      .AVCaptureSessionDidStopRunning,
      .AVCaptureSessionDidStartRunning,
      .AVCaptureDeviceSubjectAreaDidChange,
      // .AVCaptureInputPortFormatDescriptionDidChange,
    ]
    for name in names {
      NotificationCenter.default.publisher(for: name)
        .sink(receiveValue: receiveNotification(notification:))
        .store(in: &cancellables)
    }
    NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
      .sink(receiveValue: rotated)
      .store(in: &cancellables)
  }

  func receiveNotification(notification: Notification) {
    switch notification.name {
    case .AVCaptureSessionDidStopRunning:
      print(">>> Session unloaded")
      // setupNewRandomCamera()
    case .AVCaptureSessionRuntimeError:
      print(">>> Runtime error (\(notification.debugDescription), next camera preset...")
      // unloadCameraAndSetupNewOne()
    default:
      print(notification)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    nextFormatButton.addTarget(self, action: #selector(nextFormat), for: .touchUpInside)
    prevFormatButton.addTarget(self, action: #selector(unloadCameraAndSetupNewOne), for: .touchUpInside)
    nextFormatButton.setBackgroundColor(color: .red, forState: .normal)
    prevFormatButton.setBackgroundColor(color: .blue, forState: .normal)
    prevFormatButton.setTitle("Next device", for: .normal)
    debugLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    debugLabel.lineBreakMode = .byWordWrapping
    debugLabel.numberOfLines = 0
    nextFormatButton.titleLabel?.adjustsFontSizeToFitWidth = true
    view.addSubview(nextFormatButton)
    view.addSubview(prevFormatButton)
    view.addSubview(debugLabel)
    AVCaptureDevice.requestAccess(for: .audio) { _ in
      AVCaptureDevice.requestAccess(for: .video) { _ in
        self.setupSession()
      }
    }
  }

  @objc func restartSession() {
    session.stopRunning()
    setupSession()
  }

  func setupNewRandomCamera() {
    guard let session = session, session.connections.isEmpty else {
      print(">>> Session already has connections!")
      return
    }
    try? FileManager.default.removeItem(at: Self.videoUrl)
    print(">>> Switching to new camera")
    let cameras = self.cameras()
    maxDevices = cameras.count
    let randomDevice = cameras[deviceCounter]
    formatCounter = 0
    formatReady = 0
    // describe(device: randomDevice)
    // swiftlint:disable force_try
    let input = try! AVCaptureDeviceInput(device: randomDevice)
    session.addInputWithNoConnections(input)
    nextFormat()
    deviceCounter = (deviceCounter + 1) % maxDevices
    session.addConnection(AVCaptureConnection(inputPort: input.ports.first!, videoPreviewLayer: previewLayer))
    let output = AVCaptureVideoDataOutput()
    output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
    session.addOutput(output)
    videoWriter = try! AVAssetWriter(outputURL: CameraViewController.videoUrl, fileType: .mov)
    videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: randomDevice.activeFormat.size.0,
      AVVideoHeightKey: randomDevice.activeFormat.size.1,
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 2300000,
      ],
    ])
    videoWriterInput?.expectsMediaDataInRealTime = true
    videoWriter.add(videoWriterInput!)
    //    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
    //      self.videoWriterInput?.markAsFinished()
    //      self.videoWriterInput = nil
    //      // self.videoWriter.endSession(atSourceTime: CMTime(seconds: 10, preferredTimescale: 1))
    //      self.videoWriter.finishWriting {
    //        DispatchQueue.main.async {
    //          let player = AVPlayer(url: CameraViewController.videoUrl)
    //          let playerController = AVPlayerViewController()
    //          playerController.player = player
    //          self.present(playerController, animated: true) {
    //            player.play()
    //          }
    //        }
    //
    //      }
    //    }
    allFormats()
    session.startRunning()
  }

  func allFormats() {
    let allDevices = cameras().filter { $0.position == .back }
    var formats = [String: [(AVCaptureDevice, AVCaptureDevice.Format)]]()
    for camera in allDevices {
      for format in camera.formats {
        let key = "\(format.size.0)x\(format.size.1)"
        if formats[key] == nil {
          formats[key] = []
        }
        formats[key]?.append((camera, format))
      }
    }
    print(123)
  }

  @objc func unloadCameraAndSetupNewOne() {
    debugLabel.alpha = 0
    for connection in session.connections {
      session.removeConnection(connection)
    }
    for input in session.inputs {
      session.removeInput(input)
    }
    for output in session.outputs {
      session.removeOutput(output)
    }
    if session.isRunning {
      session.stopRunning()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
      self.setupNewRandomCamera()
    }
  }

  // https://stackoverflow.com/a/35607761
  func describe(device: AVCaptureDevice) {
    DispatchQueue.main.async {
      // let fmtDesc = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
      let fps = device.activeFormat.videoSupportedFrameRateRanges[0]
      let autofocus: [AVCaptureDevice.Format.AutoFocusSystem: String] = [
        .none: "none",
        .contrastDetection: "contrast detection",
        .phaseDetection: "phase detection",
      ]
      self.debugLabel.text = [
        "device: \(self.deviceCounter + 1)/\(self.maxDevices), format: \(self.formatCounter + 1)/\(self.maxFormats)",
        device.systemPressureState.level.rawValue,
        device.uniqueID,
        "size: \(device.activeFormat.size)",
        "\(Int(fps.minFrameRate)) - \(Int(fps.maxFrameRate)) fps",
        "autofocus: \(autofocus[device.activeFormat.autoFocusSystem]!)",
        "fpses: \(device.activeFormat.videoSupportedFrameRateRanges.count)",
        "fov: \(device.activeFormat.videoFieldOfView)",
      ].joined(separator: "\n")
      self.debugLabel.alpha = 1
      self.nextFormatButton.setTitle(
        "\(Int(device.activeVideoMaxFrameDuration.milliseconds))" +
        "/\(device.activeVideoMinFrameDuration.milliseconds)ms",
      for: .normal)
    }
  }

  var deviceCounter = 0
  var maxDevices = 0
  var formatCounter = 0
  var maxFormats = 0

  @objc func nextFormat() {
    // swiftlint:disable force_cast
    let input = session.inputs[0] as! AVCaptureDeviceInput
    let device = input.device
    // swiftlint:disable force_try
    try! device.lockForConfiguration()
    let formats = device.formats.sorted { $0.sizeScalar > $1.sizeScalar }
    maxFormats = formats.count
    let newFormat = device.formats[formatCounter]
    device.activeFormat = newFormat
    let conf = newFormat.videoSupportedFrameRateRanges[0]
    device.activeVideoMaxFrameDuration = conf.minFrameDuration
    device.activeVideoMinFrameDuration = conf.minFrameDuration
    device.unlockForConfiguration()
    describe(device: device)
    formatCounter = (formatCounter + 1) % maxFormats
  }

  var videoWriter: AVAssetWriter!
  var videoWriterInput: AVAssetWriterInput?
  static var videoUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("movie.mov")

  @objc func prevFormat() {

  }

  func setupSession() {
    session = AVCaptureSession()
    previewLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
    previewLayer.videoGravity = .resizeAspect
    setupNewRandomCamera()
    DispatchQueue.main.async {
      self.previewLayer.frame = self.view.bounds
      self.view.layer.insertSublayer(self.previewLayer, at: 0)
    }
  }

  func cameras() -> [AVCaptureDevice] {
    let session = AVCaptureDevice.DiscoverySession(
      deviceTypes: cameraDeviceTypes,
      mediaType: .video,
      position: .unspecified
    )
    return session.devices
  }

  var formatReady = 0
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    if videoWriter.status == .unknown {
      let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
      videoWriter.startWriting()
      videoWriter.startSession(atSourceTime: startTime)
    }
    if let input = videoWriterInput, input.isReadyForMoreMediaData {
      input.append(sampleBuffer)
    }
  }
}

extension AVCaptureDevice.Format {
  var size: (Int, Int) {
    let fmtDesc = CMVideoFormatDescriptionGetDimensions(formatDescription)
    return (Int(fmtDesc.width), Int(fmtDesc.height))
  }

  var sizeScalar: Int {
    size.0 * size.1
  }
}

extension CMTime {
  var milliseconds: Int {
    Int(CMTimeGetSeconds(self) * 1000)
  }
}

private let cameraDeviceTypes: [AVCaptureDevice.DeviceType] = [
  .builtInDualCamera,
  .builtInTripleCamera,
  .builtInTelephotoCamera,
  .builtInDualWideCamera,
  .builtInDualWideCamera,
  .builtInWideAngleCamera,
  .builtInUltraWideCamera,
  .builtInTrueDepthCamera,
]

protocol AvShit {
  func load()
}

extension UIButton {
  func setBackgroundColor(color: UIColor, forState: UIControl.State) {
    self.clipsToBounds = true  // add this to maintain corner radius
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    if let context = UIGraphicsGetCurrentContext() {
      context.setFillColor(color.cgColor)
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
      let colorImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      self.setBackgroundImage(colorImage, for: forState)
    }
  }
}
