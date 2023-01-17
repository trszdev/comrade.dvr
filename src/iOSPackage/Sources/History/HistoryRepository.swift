import Util
import Foundation
import AVFoundation

public protocol HistoryRepository {
  func loadHistory() async -> [HistoryState.Section]
  func remove(_ item: HistoryItem) async
}

public final class HistoryRepositoryStub: HistoryRepository {
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

final class HistoryRepositoryImpl: HistoryRepository {
  private let datedFileManager: DatedFileManager
  private let calendar = Calendar(identifier: .gregorian)

  init(datedFileManager: DatedFileManager) {
    self.datedFileManager = datedFileManager
  }

  public func loadHistory() async -> [HistoryState.Section] {
    let items = await withTaskGroup(of: HistoryItem?.self, returning: [HistoryItem].self) { group in
      for entry in datedFileManager.entries() {
        group.addTask(priority: .userInitiated) {
          await entryToItem(entry)
        }
      }
      var items = [HistoryItem]()
      for await item in group where item != nil {
        items.append(item!)
      }
      return items.sorted { $0.createdAt < $1.createdAt }
    }
    var itemsByDay = [Date: [HistoryItem]]()
    for item in items {
      let day = calendar.startOfDay(for: item.createdAt)
      itemsByDay[day, default: []].append(item)
    }
    let sections = itemsByDay.sorted { $0.key < $1.key }.map { HistoryState.Section(day: $0.key, items: $0.value) }
    return sections
  }

  public func remove(_ item: HistoryItem) async {
    datedFileManager.remove(url: item.url)
  }
}

private func entryToItem(_ entry: DatedFileManagerEntry) async -> HistoryItem? {
  await withCheckedContinuation { continuation in
    let asset = AVAsset(url: entry.url)
    asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
      let tracks = asset.tracks
      let containsVideo = tracks.contains { $0.mediaType == .video }
      let containsAudio = tracks.contains { $0.mediaType == .audio }
      guard containsAudio || containsVideo else {
        continuation.resume(with: .success(nil))
        return
      }
      let item = HistoryItem(
        createdAt: entry.date,
        duration: asset.duration.seconds,
        url: entry.url,
        size: entry.size,
        deviceName: entry.name,
        previewType: containsVideo ? .video : .audio
      )
      continuation.resume(with: .success(item))
    }
  }
}
