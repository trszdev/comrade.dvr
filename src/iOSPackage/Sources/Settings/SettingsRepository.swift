import Foundation
import Util

public protocol SettingsRepository {
  func save(settings: Settings) async
  func load() async -> Settings
}

public struct SettingsRepositoryStub: SettingsRepository {
  public init() {}

  public func save(settings: Settings) async {
  }

  public func load() async -> Settings {
    .init()
  }
}

struct SettingsUserDefaultsRepository: SettingsRepository {
  let userDefaults: UserDefaults

  func save(settings: Settings) async {
    do {
      let data = try settings.jsonData(encoder: .init())
      userDefaults.set(data, forKey: "settings")
    } catch {
      Assert.unexpected(error.localizedDescription)
    }
  }

  func load() async -> Settings {
    if let data = userDefaults.data(forKey: "settings") {
      do {
        let decoded = try JSONDecoder().decode(Settings.self, from: data)
        return decoded
      } catch {
        log.warn(error: error)
      }
    }
    return .init()
  }
}
