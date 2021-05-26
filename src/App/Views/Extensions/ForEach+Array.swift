import SwiftUI

extension ForEach where Data == Range<Int>, ID == Int, Content: View {
  init<Element>(array: [Element], @ViewBuilder content: @escaping (Element) -> Content) {
    self.init(0..<array.count) { index in
      content(array[index])
    }
  }

  init(array: [Content]) {
    self.init(0..<array.count) { index in
      array[index]
    }
  }
}
