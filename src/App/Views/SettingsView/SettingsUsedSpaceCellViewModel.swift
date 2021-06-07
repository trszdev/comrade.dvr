import SwiftUI
import Combine

protocol SettingsCellUsedSpace: ObservableObject {
  associatedtype Value: Codable
  var value: Value { get }
  var valuePublished: Published<Value> { get }
  var valuePublisher: Published<Value>.Publisher { get }
  func update(newValue: Value)
}
