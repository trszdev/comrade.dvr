public protocol HistoryRepository {
  func loadHistory() async -> [HistoryState.Section]
  func remove(_ item: HistoryItem) async
}

public actor HistoryRepositoryStub: HistoryRepository {
  public init() {}
  public static let shared = HistoryRepositoryStub()

  public func loadHistory() async -> [HistoryState.Section] {
    sections
  }

  public func remove(_ item: HistoryItem) async {
    sections = sections
      .map { section in .init(day: section.day, items: section.items.filter { $0 != item }) }
      .filter { !$0.items.isEmpty }
  }

  private var sections: [HistoryState.Section] = [.mock, .mock, .mock]
}
