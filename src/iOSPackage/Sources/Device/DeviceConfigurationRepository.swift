import Foundation
import Util

public protocol DeviceConfigurationRepository {
  func load() async -> DeviceConfiguration
  func save(deviceConfiguration: DeviceConfiguration) async
}

public struct DeviceConfigurationRepositoryStub: DeviceConfigurationRepository {
  public init() {}
  public func load() async -> DeviceConfiguration { .init() }
  public func save(deviceConfiguration: DeviceConfiguration) async {}
}

struct DeviceConfigurationRepositoryImpl: DeviceConfigurationRepository {
  let userDefaults: UserDefaults
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  func load() async -> DeviceConfiguration {
    if let data = userDefaults.data(forKey: key) {
      do {
        let decoded = try JSONDecoder().decode(DeviceConfiguration.self, from: data)
        return decoded
      } catch {
        log.warn(error: error)
      }
    }
    return .init()
  }

  func save(deviceConfiguration: DeviceConfiguration) async {
    do {
      let data = try deviceConfiguration.jsonData(encoder: .init())
      userDefaults.set(data, forKey: key)
    } catch {
      Assert.unexpected(error.localizedDescription)
    }
  }
}

private let key = "DeviceConfiguration"
