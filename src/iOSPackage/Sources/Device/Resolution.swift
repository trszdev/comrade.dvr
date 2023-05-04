public struct Resolution: Codable, Hashable, Comparable {
  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }

  public static let known: [Self] = [.p2160, .p1440, .p1080, .p720, .p480]
  public static let p2160 = Self(width: 3840, height: 2160)
  public static let p1440 = Self(width: 2560, height: 1440)
  public static let p1080 = Self(width: 1920, height: 1080)
  public static let p720 = Self(width: 1280, height: 720)
  public static let p480 = Self(width: 640, height: 480)

  public let width: Int
  public let height: Int

  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.width < rhs.width && lhs.height < rhs.height
  }
}
