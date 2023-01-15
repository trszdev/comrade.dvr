import Foundation

public protocol DatedFileManager {
  var totalFileSize: FileSize { get }
  func removeFiles(toFit capacity: FileSize?)
  func url(name: String, date: Date) -> URL
  func files(name: String) -> [(URL, Date)]
}

public struct DatedFileManagerStub: DatedFileManager {
  public var totalFileSize: FileSize { .zero }
  public func removeFiles(toFit capacity: FileSize?) {}
  public func url(name: String, date: Date) -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(name, isDirectory: true)
      .appendingPathComponent(UUID().uuidString)
  }
  public func files(name: String) -> [(URL, Date)] { [] }
}

struct DatedFileManagerImpl: DatedFileManager {
  let fileManager: FileManager
  let rootDirectory: URL

  var totalFileSize: FileSize {
    makeDirectory()
    return rootDirectory.directoryTotalAllocatedSize(fileManager: fileManager)
  }

  func removeFiles(toFit capacity: FileSize?) {
    makeDirectory()
    guard let capacity else { return }
    var files = rootDirectory.contents(fileManager: fileManager)
    files.sort { $0.1 < $1.1 }
    for (url, _) in files where totalFileSize > capacity {
      print("delete", url)
      do {
        try fileManager.removeItem(at: url)
      } catch {
        log.warn(error: error)
        log.warn("Error during cleanup")
      }
    }
  }

  func url(name: String, date: Date) -> URL {
    let namedDirectory = rootDirectory.appendingPathComponent(name, isDirectory: true)
    makeDirectory(url: namedDirectory)
    let dateString = DateFormatter.dayInYearWithHourMinuteSecond.string(from: date)
    return namedDirectory.appendingPathComponent(dateString, isDirectory: false)
  }

  func files(name: String) -> [(URL, Date)] {
    let namedDirectory = rootDirectory.appendingPathComponent(name, isDirectory: true)
    makeDirectory(url: namedDirectory)
    return namedDirectory.contents(fileManager: fileManager)
  }

  private func makeDirectory(url: URL? = nil) {
    do {
      try fileManager.createDirectory(at: url ?? rootDirectory, withIntermediateDirectories: true)
    } catch {
      log.warn(error: error)
      log.warn("Errors during creating folder \(url ?? rootDirectory)")
    }
  }
}

private extension URL {
  func directoryTotalAllocatedSize(fileManager: FileManager) -> FileSize {
    let urls = fileManager.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
    let bytes = urls.filter { $0.lastPathComponent != ".DS_Store" }.reduce(0) { (acc, url) in
      do {
        let values = try url.resourceValues(forKeys: [.fileSizeKey])
        let fileSizeBytes = values.fileSize ?? 0
        return acc + fileSizeBytes
      } catch {
        log.warn(error: error)
        log.warn("Error during counting total file size")
      }
      return acc
    }
    return FileSize(bytes: bytes)
  }

  func contents(fileManager: FileManager) -> [(URL, Date)] {
    do {
      let urls = fileManager.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
      let result = try urls.compactMap { url -> (URL, Date)? in
        let values = try url.resourceValues(forKeys: [.addedToDirectoryDateKey, .isRegularFileKey])
        guard values.isRegularFile == true else { return nil }
        let date = values.addedToDirectoryDate
        return (url, date ?? .init(timeIntervalSince1970: 0))
      }
      return result
    } catch {
      log.warn(error: error)
      log.warn("Error while listing dir: \(self)")
    }
    return []
  }
}
