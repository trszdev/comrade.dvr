import Foundation

protocol AppLocale {
  var currentLocale: Locale? { get }
  func themeName(_ themeSetting: ThemeSetting) -> String
  func languageName(_ languageSetting: LanguageSetting) -> String
  func timeOnly(date: Date) -> String
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
