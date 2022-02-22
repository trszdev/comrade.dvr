import ComposableArchitecture
import ThumbnailKit
import CommonUI

public struct HistoryState: Equatable {
  public struct Section: Equatable {
    public init(day: Date = .init(), items: [HistoryItem] = []) {
      self.day = day
      self.items = items
    }

    public var day: Date = .init()
    public var items: [HistoryItem] = []
    public static var mock: Self = .init(items: [.mockAudio, .mockVideo])
  }

  public init(sections: [Section] = [.mock, .mock, .mock], selectedItem: HistoryItem? = nil) {
    self.sections = sections
    self.selectedItem = selectedItem
  }

  public var sections: [Section] = []
  public var selectedItem: HistoryItem?
  public var shareItem: HistoryItem?
}

public enum HistoryAction {
  case onAppear
  case onDisappear
  case select(HistoryItem)
  case remove(HistoryItem)
  case share(HistoryItem)
}

public struct HistoryEnvironment {
  public init(routing: Routing = RoutingStub()) {
    self.routing = routing
  }

  public var routing: Routing = RoutingStub()
}

public let historyReducer = Reducer<HistoryState, HistoryAction, HistoryEnvironment> { state, action, environment in
  switch action {
  case .onAppear:
    break
  case .onDisappear:
    state.selectedItem = nil
  case .select(let item):
    state.selectedItem = item
  case .remove(let item):
    break
  case .share(let item):
    state.shareItem = item
    return .task {
      await environment.routing.tabRouting?.historyRouting?.share(animated: true)
    }
  }
  return .none
}
