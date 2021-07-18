import SwiftUI
import CameraKit

struct SelectionView<T>: View {
  @Environment(\.appLocale) var appLocale: AppLocale
  @Environment(\.theme) var theme: Theme
  let options: [(T, (AppLocale, T) -> String)]
  let onSelect: (T) -> Void

  init(options: [(T, (AppLocale, T) -> String)], onSelect: @escaping (T) -> Void) {
    self.options = options
    self.onSelect = onSelect
  }

  init(values: [T], localize: @escaping (AppLocale, T) -> String, onSelect: @escaping (T) -> Void) {
    self.options = values.map { ($0, localize) }
    self.onSelect = onSelect
  }

  var body: some View {
    TableView(sections: [
      options.enumerated().map { (index, option) in
        let (value, localize) = option
        return TableCellView(
          centerView: Text(localize(appLocale, value)).padding(.leading, 15).eraseToAnyView(),
          rightView: EmptyView().eraseToAnyView(),
          separator: index + 1 == options.count ? [] : [Edge.bottom]
        )
        .onTapGesture {
          onSelect(value)
        }
        .eraseToAnyView()
      },
    ])
  }
}

#if DEBUG

struct SelectionViewPreview: PreviewProvider {
  static var previews: some View {
    let options: [(TimeInterval, (AppLocale, TimeInterval) -> String)] = [
      (1, { $0.assetDuration($1) }),
      (2, { $0.assetDuration($1) }),
      (3, { $0.assetDuration($1) }),
      (4, { $0.assetDuration($1) }),
      (5, { $0.bitrate(CKBitrate(bitsPerSecond: Int($1))) }),
      (6, { $0.assetDuration($1) }),
      (7, { $0.assetDuration($1) }),
      (8, { $0.assetDuration($1) }),
    ]
    SelectionView(options: options, onSelect: { print($0) })
      .environment(\.theme, DarkTheme())
  }
}

#endif
