// swiftlint:disable type_body_length
import Foundation
import CameraKit

protocol AppLocale {
  var currentLocale: Locale? { get }
  func deviceName(_ deviceId: CKDeviceID) -> String
  func pressureLevelAlertText(_ pressureLevel: CKPressureLevel) -> String
  func yesNo(_ value: Bool) -> String
  func fieldOfView(_ fov: Int) -> String
  func errorBody(_ error: Error) -> String
  func orientation(_ orientation: OrientationSetting) -> String
  func size(_ size: CKSize) -> String
  func fps(_ fps: Int) -> String
  func quality(_ quality: CKQuality) -> String
  func qualityLong(_ quality: CKQuality) -> String
  func bitrate(_ bitrate: CKBitrate) -> String
  func autofocus(_ autofocus: CKAutoFocus) -> String
  func zoom(_ zoom: Double) -> String
  func deviceLocation(_ deviceLocation: CKDeviceLocation) -> String
  func polarPattern(_ polarPattern: CKPolarPattern) -> String
  func themeName(_ themeSetting: ThemeSetting) -> String
  func languageName(_ languageSetting: LanguageSetting) -> String
  func timeOnly(date: Date) -> String
  func day(date: Date) -> String
  func assetSize(_ fileSize: FileSize?) -> String
  func assetDuration(_ timeInterval: TimeInterval) -> String
  var durationString: String { get }
  var sizeString: String { get }
  var playString: String { get }
  var shareString: String { get }
  var deleteString: String { get }
  var assetsLimitString: String { get }
  var assetLengthString: String { get }
  var usedSpaceString: String { get }
  var clearAssetsString: String { get }
  var systemString: String { get }
  var languageString: String { get }
  var themeString: String { get }
  var contactUsString: String { get }
  var rateAppString: String { get }
  var recordString: String { get }
  var historyString: String { get }
  var settingsString: String { get }
  var startRecordingString: String { get }
  var lastCaptureString: String { get }
  var updatedAtString: String { get }
  var fullAppName: String { get }
  var okString: String { get }
  var cancelString: String { get }
  var appContactEmail: String { get }
  var warningString: String { get }
  var clearAllAssetsAskString: String { get }
  var clearAllAssetsConfirmString: String { get }
  var deviceEnabledString: String { get }
  var resolutionString: String { get }
  var fpsString: String { get }
  var qualityString: String { get }
  var useH265String: String { get }
  var bitrateString: String { get }
  var zoomString: String { get }
  var fieldOfViewString: String { get }
  var autofocusString: String { get }
  var deviceLocationString: String { get }
  var polarPatternString: String { get }
  var frontCameraString: String { get }
  var backCameraString: String { get }
  var microphoneString: String { get }
  var restoreDefaultSettingsString: String { get }
  var restoreDefaultSettingsAskString: String { get }
  var restoreDefaultSettingsConfirmString: String { get }
  var orientationString: String { get }
  var openSystemSettingsString: String { get }
  var errorString: String { get }
  var pressButtonTwiceString: String { get }
  var microphoneMutedString: String { get }
  var microphoneUnmutedString: String { get }
  var emptyString: String { get }
}

extension Default {
  static var appLocale: AppLocale {
    LocaleImpl()
  }
}

struct LocaleImpl: AppLocale {
  enum LanguageCode: String {
    case en
    case ru
  }

  init(languageCode: LanguageCode? = nil) {
    guard let languageCode = languageCode,
      let path = Bundle.main.path(forResource: languageCode.rawValue, ofType: "lproj")
    else {
      return
    }
    self.bundle = Bundle(path: path)
    self.currentLocale = Locale(identifier: languageCode.rawValue)
  }

  var currentLocale: Locale?

  func deviceName(_ deviceId: CKDeviceID) -> String {
    [
      CKAVCamera.back.value: backCameraString,
      CKAVCamera.front.value: frontCameraString,
      CKAVMicrophone.builtIn.value: microphoneString,
    ][deviceId] ?? deviceId.value
  }

  func pressureLevelAlertText(_ pressureLevel: CKPressureLevel) -> String {
    switch pressureLevel {
    case .nominal:
      return localizedString("SYSTEM_PRESSURE_NOMINAL_DESC")
    case .serious:
      return localizedString("SYSTEM_PRESSURE_SERIOUS_DESC")
    case .shutdown:
      return localizedString("SYSTEM_PRESSURE_SHUTDOWN_DESC")
    }
  }

  func yesNo(_ value: Bool) -> String {
    localizedString(value ? "YES" : "NO")
  }

  func fieldOfView(_ fov: Int) -> String {
    "\(fov)°"
  }

  func errorBody(_ error: Error) -> String {
    switch error {
    case CKPermissionError.noPermission(mediaType: .audio):
      return localizedString("CAMERA_PERMISSION_ALERT_TEXT")
    case CKPermissionError.noPermission(mediaType: .video):
      return localizedString("MIC_PERMISSION_ALERT_TEXT")
    case CKAVCameraSessionError.hardwareCostExceeded:
      return localizedString("HARDWARE_COST_EXCEEDED")
    case CKAVCameraSessionError.systemPressureExceeded:
      return localizedString("SYSTEM_PRESSURE_EXCEEDED")
    default:
      let template = localizedString("ERROR_OCCURED_TEMPLATE")
      return String(format: template, error.localizedDescription)
    }
  }

  func orientation(_ orientation: OrientationSetting) -> String {
    switch orientation {
    case .system:
      return systemString
    case .landscape:
      return localizedString("ORIENTATION_LANDSCAPE")
    case .portrait:
      return localizedString("ORIENTATION_PORTRAIT")
    }
  }

  func size(_ size: CKSize) -> String {
    "\(size.width)x\(size.height)"
  }

  func fps(_ fps: Int) -> String {
    "\(fps)FPS"
  }

  func quality(_ quality: CKQuality) -> String {
    switch quality {
    case .min:
      return localizedString("QUALITY_MIN")
    case .low:
      return localizedString("QUALITY_LOW")
    case .medium:
      return localizedString("QUALITY_MEDIUM")
    case .high:
      return localizedString("QUALITY_HIGH")
    case .max:
      return localizedString("QUALITY_MAX")
    }
  }

  func qualityLong(_ quality: CKQuality) -> String {
    [self.quality(quality), qualityString.lowercased()].joined(separator: " ")
  }

  func bitrate(_ bitrate: CKBitrate) -> String {
    let unitFormatter = MeasurementFormatter()
    unitFormatter.unitStyle = .medium
    unitFormatter.locale = currentLocale
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 3
    numberFormatter.locale = currentLocale
    unitFormatter.numberFormatter = numberFormatter
    let units: [UnitInformationStorage] = [.bits, .kilobits, .megabits, .gigabits, .terabits]
    let log = bitrate.bitsPerSecond > 0 ? Int(log10(Double(bitrate.bitsPerSecond)) / 3) : 0
    let unitIndex = min(units.count - 1, max(0, log))
    let size = Decimal(bitrate.bitsPerSecond) / pow(1000, unitIndex)
    let sizeDouble = NSDecimalNumber(decimal: size).doubleValue
    let bitrateString = unitFormatter.string(from: Measurement(value: sizeDouble, unit: units[unitIndex]))
    unitFormatter.unitStyle = .short
    let secondString = unitFormatter.string(from: UnitDuration.seconds)
    return "\(bitrateString)/\(secondString)"
  }

  func autofocus(_ autofocus: CKAutoFocus) -> String {
    switch autofocus {
    case .none:
      return localizedString("AUTOFOCUS_NONE")
    case .contrastDetection:
      return localizedString("AUTOFOCUS_CONTRAST")
    case .phaseDetection:
      return localizedString("AUTOFOCUS_PHASE")
    }
  }

  func zoom(_ zoom: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 2
    let value = numberFormatter.string(from: NSNumber(value: zoom)) ?? ""
    return value.appending("x")
  }

  func deviceLocation(_ deviceLocation: CKDeviceLocation) -> String {
    switch deviceLocation {
    case .back:
      return localizedString("DEVICE_LOCATION_BACK")
    case .bottom:
      return localizedString("DEVICE_LOCATION_BOTTOM")
    case .front:
      return localizedString("DEVICE_LOCATION_FRONT")
    case .left:
      return localizedString("DEVICE_LOCATION_LEFT")
    case .right:
      return localizedString("DEVICE_LOCATION_RIGHT")
    case .top:
      return localizedString("DEVICE_LOCATION_TOP")
    case .unspecified:
      return localizedString("DEVICE_LOCATION_UNSPECIFIED")
    }
  }

  func polarPattern(_ polarPattern: CKPolarPattern) -> String {
    switch polarPattern {
    case .cardioid:
      return localizedString("POLAR_PATTERN_CARDIOID")
    case .omnidirectional:
      return localizedString("POLAR_PATTERN_OMNIDIRECTIONAL")
    case .stereo:
      return localizedString("POLAR_PATTERN_STEREO")
    case .subcardioid:
      return localizedString("POLAR_PATTERN_SUBCARDIOID")
    case .unspecified:
      return localizedString("POLAR_PATTERN_UNSPECIFIED")
    }
  }

  func themeName(_ themeSetting: ThemeSetting) -> String {
    switch themeSetting {
    case .system:
      return systemString
    case .dark:
      return localizedString("DARK_THEME")
    case .light:
      return localizedString("LIGHT_THEME")
    }
  }

  func languageName(_ languageSetting: LanguageSetting) -> String {
    switch languageSetting {
    case .system:
      return systemString
    case .english:
      return localizedString("LANGUAGE_EN")
    case .russian:
      return localizedString("LANGUAGE_RU")
    }
  }

  func timeOnly(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = currentLocale
    dateFormatter.timeStyle = .medium
    dateFormatter.dateStyle = .none
    return dateFormatter.string(from: date)
  }

  func day(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = currentLocale
    dateFormatter.timeStyle = .none
    dateFormatter.dateStyle = .medium
    return dateFormatter.string(from: date)
  }

  func assetSize(_ fileSize: FileSize?) -> String {
    guard let fileSize = fileSize else {
      return "∞"
    }
    let unitFormatter = MeasurementFormatter()
    unitFormatter.unitStyle = .short
    unitFormatter.locale = currentLocale
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 3
    numberFormatter.locale = currentLocale
    unitFormatter.numberFormatter = numberFormatter
    let units: [UnitInformationStorage] = [.bytes, .kilobytes, .megabytes, .gigabytes, .terabytes]
    let log = fileSize.bytes > 0 ? Int(log2(Double(fileSize.bytes)) / 10) : 0
    let unitIndex = min(units.count - 1, max(0, log))
    let size = Decimal(fileSize.bytes) / pow(1024, unitIndex)
    let sizeDouble = NSDecimalNumber(decimal: size).doubleValue
    return unitFormatter.string(from: Measurement(value: sizeDouble, unit: units[unitIndex]))
  }

  func assetDuration(_ timeInterval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.calendar = calendar
    formatter.allowedUnits = [.day, .hour, .minute, .second]
    formatter.unitsStyle = .full
    return formatter.string(from: timeInterval)!
  }

  var durationString: String { localizedString("DURATION") }
  var sizeString: String { localizedString("SIZE") }
  var playString: String { localizedString("PLAY") }
  var shareString: String { localizedString("SHARE") }
  var deleteString: String { localizedString("DELETE") }
  var assetsLimitString: String { localizedString("ASSETS_LIMIT") }
  var assetLengthString: String { localizedString("ASSET_LENGTH") }
  var usedSpaceString: String { localizedString("USED_SPACE") }
  var clearAssetsString: String { localizedString("CLEAR_ASSETS") }
  var systemString: String { localizedString("SYSTEM") }
  var languageString: String { localizedString("LANGUAGE") }
  var themeString: String { localizedString("THEME") }
  var contactUsString: String { localizedString("CONTACT_US") }
  var rateAppString: String { localizedString("RATE_APP") }
  var recordString: String { localizedString("RECORD") }
  var historyString: String { localizedString("HISTORY") }
  var settingsString: String { localizedString("SETTINGS") }
  var startRecordingString: String { localizedString("START_RECORDING") }
  var lastCaptureString: String { localizedString("LAST_CAPTURE") }
  var updatedAtString: String { localizedString("UPDATED_AT") }
  var fullAppName: String { "ComradeDVR v1.0.0" }
  var okString: String { localizedString("OK") }
  var cancelString: String { localizedString("CANCEL") }
  var appContactEmail: String { "help@comradedvr.app" }
  var warningString: String { localizedString("WARNING") }
  var clearAllAssetsAskString: String { localizedString("CLEAR_ALL_ASSETS_ASK") }
  var clearAllAssetsConfirmString: String { localizedString("CLEAR_ALL_ASSETS_CONFIRM") }
  var deviceEnabledString: String { localizedString("DEVICE_ENABLED") }
  var resolutionString: String { localizedString("RESOLUTION") }
  var fpsString: String { localizedString("FPS") }
  var qualityString: String { localizedString("QUALITY") }
  var useH265String: String { localizedString("USE_H265") }
  var bitrateString: String { localizedString("BITRATE") }
  var zoomString: String { localizedString("ZOOM") }
  var fieldOfViewString: String { localizedString("FIELD_OF_VIEW") }
  var autofocusString: String { localizedString("AUTOFOCUS") }
  var deviceLocationString: String { localizedString("DEVICE_LOCATION") }
  var polarPatternString: String { localizedString("POLAR_PATTERN") }
  var frontCameraString: String { localizedString("FRONT_CAMERA") }
  var backCameraString: String { localizedString("BACK_CAMERA") }
  var microphoneString: String { localizedString("MICROPHONE") }
  var restoreDefaultSettingsString: String { localizedString("RESTORE_DEFAULT_SETTINGS") }
  var restoreDefaultSettingsAskString: String { localizedString("RESTORE_DEFAULT_SETTINGS_ASK") }
  var restoreDefaultSettingsConfirmString: String { localizedString("RESTORE_DEFAULT_SETTINGS_CONFIRM") }
  var orientationString: String { localizedString("ORIENTATION") }
  var openSystemSettingsString: String { localizedString("OPEN_SYSTEM_SETTINGS") }
  var errorString: String { localizedString("ERROR") }
  var pressButtonTwiceString: String { localizedString("PRESS_BUTTON_TWICE") }
  var microphoneMutedString: String { localizedString("MICROPHONE_MUTED") }
  var microphoneUnmutedString: String { localizedString("MICROPHONE_UNMUTED") }
  var emptyString: String { localizedString("EMPTY") }

  private func localizedString(_ key: String) -> String {
    if let bundle = bundle {
      return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
    return NSLocalizedString(key, comment: "")
  }

  private var calendar: Calendar {
    var calendar = Calendar.current
    calendar.locale = currentLocale
    return calendar
  }

  private var bundle: Bundle?
  private var languageCode: LanguageCode?
}
