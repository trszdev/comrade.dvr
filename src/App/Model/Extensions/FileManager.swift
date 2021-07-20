import Foundation

extension FileManager {
  func fileSize(url: URL) -> FileSize? {
    do {
      let attr = try attributesOfItem(atPath: url.path)
      if (attr as NSDictionary).fileType() == "NSFileTypeRegular" {
        let bytes = (attr as NSDictionary).fileSize()
        return FileSize(bytes: Int(bytes))
      }
      let urls = enumerator(at: url, includingPropertiesForKeys: nil)?.allObjects as? [URL] ?? []
      let totalBytes = urls.lazy.reduce(0) { $0 + $1.totalFileAllocatedSize }
      return FileSize(bytes: totalBytes)
    } catch {
      return nil
    }
  }

  var documentsDirectory: URL {
    urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}

private extension URL {
  var totalFileAllocatedSize: Int {
    (try? resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize) ?? 0
  }
}
