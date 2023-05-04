import SwiftUI
import ComposableArchitecture
import ComposableArchitectureExtensions
import CommonUI
import AVKit
import ThumbnailKit

public struct HistoryView: View {
  @Environment(\.verticalSizeClass) var verticalSizeClass
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance

  public init(store: Store<HistoryState, HistoryAction>, observableImageCache: ObservableImageCache = .init()) {
    self.viewStore = ViewStore(store)
    self.observableImageCache = observableImageCache
  }

  public var body: some View {
    ZStack {
      appearance.color(.mainBackgroundColor).ignoresSafeArea()

      view
    }
    .onChange(of: viewStore.selectedItem) { newItem in
      player?.pause()
      if let newItem = newItem {
        player = .init(url: newItem.url)
        player?.play()
      } else {
        player = nil
      }
    }
    .onAppear {
      viewStore.send(.onAppear)
    }
    .onDisappear {
      player?.pause()
      viewStore.send(.onDisappear)
    }
  }

  @ViewBuilder private var view: some View {
    if viewStore.sections.isEmpty {
      VStack {
        Text(language.string(.noHistoryTitle))
          .foregroundColor(appearance.color(.textColorDefault))
          .bold()

        Text(language.string(.noHistorySubtitle))
          .foregroundColor(appearance.color(.textColorDisabled))
      }
    } else if verticalSizeClass == .compact {
      HStack(spacing: 0) {
        previewView

        listView(isVertical: false)
          .frame(maxWidth: 200)
      }
      .previewContainer(observableImageCache)
    } else {
      VStack(spacing: 0) {
        previewView
          .frame(maxHeight: 200)

        listView(isVertical: true)
      }
      .previewContainer(observableImageCache)
    }
  }

  @State private var player: AVPlayer?

  private var previewView: some View {
    VideoPlayer(player: player ?? .init())
      .overlay(player == nil ? Color.black : nil)
  }

  private func listView(isVertical: Bool) -> some View {
    List {
      ForEach(viewStore.sections, id: \.day) { section in
        Section(content: {
          ForEach(section.items, id: \.url) { item in
            let isSelected = viewStore.selectedItem == item
            Button {
              viewStore.send(.select(item))
            } label: {
              if isVertical {
                HistoryItemVerticalView(item: item)
              } else {
                HistoryItemCompactView(item: item)
              }
            }
            .opacity(viewStore.selectedItem == nil ? 1 : (isSelected ? 1 : 0.5))
            .contextMenu {
              contextMenu(for: item)
            }
          }
        }, header: {
          Text(language.format(date: section.day, timeStyle: .none, dateStyle: isVertical ? .full : .medium))
        })
      }
    }
    .listStyle(PlainListStyle())
  }

  @ViewBuilder private func contextMenu(for historyItem: HistoryItem) -> some View {
    Button {
      viewStore.send(.select(historyItem))
    } label: {
      Label(language.string(.play), systemImage: "play")
    }

    Button {
      viewStore.send(.share(historyItem))
    } label: {
      Label(language.string(.share), systemImage: "square.and.arrow.up")
    }

    DestructiveButton {
      viewStore.send(.remove(historyItem))
    } label: {
      Label(language.string(.delete), systemImage: "trash")
    }
  }

  @ObservedObject private var viewStore: ViewStore<HistoryState, HistoryAction>
  private let observableImageCache: ObservableImageCache
}

@available(iOS 15.0, *)
struct HistoryViewPreviews: PreviewProvider {
  static var previews: some View {
    HistoryView(store: historyReducer.store(initialState: .init(), environment: .init()))

    HistoryView(store: historyReducer.store(initialState: .init(), environment: .init()))
      .previewInterfaceOrientation(.landscapeRight)
  }
}
