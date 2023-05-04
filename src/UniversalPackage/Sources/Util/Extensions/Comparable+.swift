public extension Comparable {
  mutating func clamp(_ range: ClosedRange<Self>) {
    self = min(max(self, range.lowerBound), range.upperBound)
  }
}

public extension RandomAccessCollection where Element: Comparable {
  func closest(to value: Element) -> Element? {
    sorted().first { $0 >= value } ?? last
  }
}

public extension ClosedRange {
  func union(_ other: ClosedRange<Bound>) -> ClosedRange<Bound> {
    Swift.min(lowerBound, other.lowerBound)...Swift.max(upperBound, other.upperBound)
  }
}
