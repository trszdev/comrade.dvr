public enum CKPermissionError: Error {
  case noDescription(mediaType: CKMediaType)
  case noPermission(mediaType: CKMediaType)
}
