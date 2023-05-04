import Foundation

public extension FileManager {
  var documentsDirectory: URL {
    urls(for: .documentDirectory, in: .userDomainMask)[0]
  }

  var recordingsDirectory: URL {
    documentsDirectory.appendingPathComponent("recordings", isDirectory: true)
  }
}
