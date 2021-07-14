import SwiftUI
import CameraKit

protocol HistorySelectionViewModel {
  var selectedDevice: CKDeviceID? { get }
  var selectedDevicePublished: Published<CKDeviceID?> { get }
  var selectedDevicePublisher: Published<CKDeviceID?>.Publisher { get }

  var selectedDay: Date? { get }
  var selectedDayPublished: Published<Date?> { get }
  var selectedDayPublisher: Published<Date?>.Publisher { get }

  var selectedPlayerUrl: URL? { get set }
  var selectedPlayerUrlPublished: Published<URL?> { get }
  var selectedPlayerUrlPublisher: Published<URL?>.Publisher { get }
}
