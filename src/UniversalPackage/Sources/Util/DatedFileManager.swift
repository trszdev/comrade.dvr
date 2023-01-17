import Foundation

public protocol DatedFileManager {
  var totalFileSize: FileSize { get }
  func removeFiles(toFit capacity: FileSize?)
  func remove(url: URL)
  func url(name: String, date: Date) -> URL
  func entries(name: String) -> [DatedFileManagerEntry]
  func entries() -> [DatedFileManagerEntry]
}

public struct DatedFileManagerEntry: Hashable {
  public init(name: String, url: URL, date: Date, size: FileSize) {
    self.name = name
    self.url = url
    self.date = date
    self.size = size
  }

  public let name: String
  public let url: URL
  public let date: Date
  public let size: FileSize
}

public struct DatedFileManagerStub: DatedFileManager {
  public func remove(url: URL) {}
  public func entries() -> [DatedFileManagerEntry] { [] }
  public var totalFileSize: FileSize { .zero }
  public func removeFiles(toFit capacity: FileSize?) {}
  public func url(name: String, date: Date) -> URL {
    FileManager.default.documentsDirectory
      .appendingPathComponent(name, isDirectory: true)
      .appendingPathComponent(UUID().uuidString, isDirectory: false)
  }
  public func entries(name: String) -> [DatedFileManagerEntry] { [] }
}

struct DatedFileManagerImpl: DatedFileManager {
  let fileManager: FileManager
  let rootDirectory: URL

  var totalFileSize: FileSize {
    let totalBytes = entries().map(\.size).reduce(0) { $0 + $1.bytes }
    return .init(bytes: totalBytes)
  }

  func removeFiles(toFit capacity: FileSize?) {
    makeDirectory()
    guard let capacity else { return }
    var entries = contents(url: rootDirectory)
    entries.sort { $0.date < $1.date }
    for entry in entries where totalFileSize > capacity {
      remove(url: entry.url)
    }
  }

  func remove(url: URL) {
    makeDirectory()
    do {
      try fileManager.removeItem(at: url)
    } catch {
      log.warn(error: error)
      log.warn("Error during cleanup")
    }
  }

  func url(name: String, date: Date) -> URL {
    let namedDirectory = rootDirectory.appendingPathComponent(name, isDirectory: true)
    makeDirectory(url: namedDirectory)
    let dateString = DateFormatter.dayInYearWithHourMinuteSecond.string(from: date)
    return namedDirectory.appendingPathComponent(dateString, isDirectory: false)
  }

  func entries() -> [DatedFileManagerEntry] {
    let namedDirectory = rootDirectory
    makeDirectory(url: namedDirectory)
    return contents(url: namedDirectory)
  }

  func entries(name: String) -> [DatedFileManagerEntry] {
    let namedDirectory = rootDirectory.appendingPathComponent(name, isDirectory: true)
    makeDirectory(url: namedDirectory)
    return contents(url: namedDirectory)
  }

  private func makeDirectory(url: URL? = nil) {
    do {
      try fileManager.createDirectory(at: url ?? rootDirectory, withIntermediateDirectories: true)
    } catch {
      log.warn(error: error)
      log.warn("Errors during creating folder \(url ?? rootDirectory)")
    }
  }

  private func contents(url: URL) -> [DatedFileManagerEntry] {
    do {
      let urls = fileManager.enumerator(at: url, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
      let result = try urls.compactMap { url -> DatedFileManagerEntry? in
        let values = try url.resourceValues(forKeys: [.creationDateKey, .isRegularFileKey, .fileSizeKey])
        guard values.isRegularFile == true else { return nil }
        let name = url.pathComponents.dropLast().last ?? ""
        let size = FileSize(bytes: values.fileSize ?? 0)
        let date = values.creationDate ?? Date(timeIntervalSince1970: 0)
        return .init(name: name, url: url, date: date, size: size)
      }
      return result
    } catch {
      log.warn(error: error)
      log.warn("Error while listing dir: \(self)")
    }
    return []
  }
}
