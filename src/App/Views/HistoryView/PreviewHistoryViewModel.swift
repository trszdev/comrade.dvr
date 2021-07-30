import SwiftUI
import CameraKit

final class PreviewHistoryViewModel: HistoryViewModel {
  func presentSelectDeviceScreen() {
  }

  func presentSelectDayScreen() {
  }

  @Published var selectedDevice: CKDeviceID? = CKAVCamera.back.value
  var selectedDevicePublished: Published<CKDeviceID?> { _selectedDevice }
  var selectedDevicePublisher: Published<CKDeviceID?>.Publisher { $selectedDevice }

  @Published var selectedDay: Date? = captureDate
  var selectedDayPublished: Published<Date?> { _selectedDay }
  var selectedDayPublisher: Published<Date?>.Publisher { $selectedDay }

  @Published var selectedPlayerUrl: URL? = Bundle.main.url(forResource: "preview", withExtension: "mp4")
  var selectedPlayerUrlPublished: Published<URL?> { _selectedPlayerUrl }
  var selectedPlayerUrlPublisher: Published<URL?>.Publisher { $selectedPlayerUrl }

  static let captureDate: Date = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.date(from: "2021-07-30T12:49:25")!
  }()
}
