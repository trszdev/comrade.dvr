public extension FileSize {
  static func bytes(_ bytes: Int) -> FileSize {
    FileSize(bytes: bytes)
  }

  static func kilobytes(_ kilobytes: Int) -> FileSize {
    FileSize(bytes: kilobytes * 1024)
  }

  static func megabytes(_ megabytes: Int) -> FileSize {
    FileSize(bytes: megabytes * 1024 * 1024)
  }

  static func gigabytes(_ gigabytes: Int) -> FileSize {
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
