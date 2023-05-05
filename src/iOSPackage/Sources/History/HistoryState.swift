import ComposableArchitecture
import ThumbnailKit
import CommonUI
import Util
import Foundation

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

  public init(sections: [Section] = [], selectedItem: HistoryItem? = nil) {
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
  case reload
  case loaded([HistoryState.Section])
  case select(HistoryItem)
  case remove(HistoryItem)
  case share(HistoryItem)
}

public struct HistoryEnvironment {
  public init(routing: Routing = RoutingStub(), repository: HistoryRepository = HistoryRepositoryStub.shared) {
    self.routing = routing
    self.repository = repository
  }

  public var routing: Routing = RoutingStub()
  public var repository: HistoryRepository = HistoryRepositoryStub.shared
}

public let historyReducer = AnyReducer<HistoryState, HistoryAction, HistoryEnvironment> { state, action, environment in
  switch action {
  case .onAppear:
    return .init(value: .reload)
  case .reload:
    return .task {
      let sections = await environment.repository.loadHistory()
      return .loaded(sections)
    }
  case .loaded(let sections):
    guard sections != state.sections else { return .none }
    state.sections = sections
    state.selectedItem = nil
  case .onDisappear:
    state.selectedItem = nil
  case .select(let item):
    state.selectedItem = item
  case .remove(let item):
    return .task {
      try? await Task.sleep(.seconds(0.7)) // solves context menu glitch
      await environment.repository.remove(item)
      return .reload
    }
  case .share(let item):
    return .fireAndForget {
      await environment.routing.tabRouting?.historyRouting?.share(url: item.url, animated: true)
    }
  }
  return .none
}
