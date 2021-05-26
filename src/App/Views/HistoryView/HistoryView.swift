import SwiftUI

private struct Item: Hashable, Identifiable {
  let id = UUID()
  let title: String
  let description: String
}

struct HistoryView: View {
  @Environment(\.theme) var theme: Theme

  private let items = [
    Item(title: "10:30", description: "duration: 10m, size: 1,2Gb"),
    Item(title: "10:31", description: "duration: 10m, size: 1,2Gb"),
    Item(title: "10:32", description: "duration: 10m, size: 1,2Gb"),
    Item(title: "10:33", description: "duration: 10m, size: 1,2Gb"),
    Item(title: "10:34", description: "duration: 10m, size: 1,2Gb"),
  ]

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        menuView(height: geometry.size.height)
        playerView(height: geometry.size.height)
        historyView(bottomPadding: geometry.safeAreaInsets.bottom)
      }
      .background(theme.mainBackgroundColor.ignoresSafeArea())
    }
  }

  func menuView(height: CGFloat) -> some View {
    HistoryMenuView(title: "Front camera", subtitle: "21 January 2008")
  }

  func historyView(bottomPadding: CGFloat) -> some View {
    HistoryTableView()
//    CustomScrollView {
//      LazyVStack(spacing: 0) {
//        ForEach(items) { item in
//          HistoryCellView(date: item.title, description: item.description)
//        }
//      }
//      .edgesIgnoringSafeArea(.bottom)
//      // .padding(.bottom, bottomPadding)
//    }
//    .edgesIgnoringSafeArea(.bottom)
  }

  func playerView(height: CGFloat) -> some View {
    let idealHeight = min(height / 2, 300)
    return Rectangle()
      .overlay(
        Image(sfSymbol: .play)
          .fitResizable
          .foregroundColor(.white)
          .frame(maxWidth: 50)
      )
      .frame(height: idealHeight)
      .background(Color.red.edgesIgnoringSafeArea(.horizontal).frame(height: idealHeight))
  }

  func dateView(_ text: String) -> some View {
    ZStack {
      Color.red.ignoresSafeArea()
      HStack {
        Text(text).font(.title2)
        Spacer()
      }
    }
  }

  var itemView: some View {
    HStack(alignment: .top) {
      Rectangle().frame(width: 60, height: 60)
      VStack(alignment: .leading) {
        Text("10:30").font(.title)
        Text("10:52:30 - 1,2gb").foregroundColor(.gray)
      }
      Spacer()
    }
    .padding()
    .border(width: 0.5, edges: [.bottom], color: theme.textColor)
  }
}

#if DEBUG

struct HistoryViewPreview: PreviewProvider {
  static var previews: some View {
    HistoryView().environment(\.theme, DarkTheme())
  }
}

#endif
