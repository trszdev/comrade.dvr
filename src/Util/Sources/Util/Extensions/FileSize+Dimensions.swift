public extension FileSize {
  static func from(bytes: Int) -> FileSize {
    FileSize(bytes: bytes)
  }

  static func from(kilobytes: Int) -> FileSize {
    FileSize(bytes: kilobytes * 1024)
  }

  static func from(megabytes: Int) -> FileSize {
    FileSize(bytes: megabytes * 1024 * 1024)
  }

  static func from(gigabytes: Int) -> FileSize {
    FileSize(bytes: gigabytes * 1024 * 1024 * 1024)
  }

  var kilobytes: Double {
    Double(bytes) / 1024
  }

  var megabytes: Double {
    Double(bytes) / (1024 * 1024)
  }

  var gigabytes: Double {
    Double(bytes) / (1024 * 1024 * 1024)
  }
}
