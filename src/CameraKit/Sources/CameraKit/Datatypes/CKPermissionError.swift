import Foundation

public enum CKPermissionError: Error {
  case noDescription(mediaType: CKMediaType)
  case noPermission(mediaType: CKMediaType)
}

extension CKPermissionError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case let .noDescription(mediaType):
      return "No description for \(mediaType.infoPlistKey)"
    case let .noPermission(mediaType):
      return "No permission for \(mediaType.infoPlistKey)"
    }
  }
}
