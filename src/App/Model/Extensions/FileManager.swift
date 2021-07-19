import Foundation

extension FileManager {
  func fileSize(url: URL) -> FileSize? {
    do {
      let attr = try attributesOfItem(atPath: url.path)
      let bytes = (attr as NSDictionary).fileSize()
      return FileSize(bytes: Int(bytes))
    } catch {
      return nil
    }
  }

  var documentsDirectory: URL {
    urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}
