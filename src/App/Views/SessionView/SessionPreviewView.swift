import SwiftUI

struct SessionPreviewView: View {
  let previews: [AnyView]
  let pinnedView: AnyView

  var body: some View {
    VStack {
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHGrid(rows: [GridItem(.fixed(cameraPreviewSize))], pinnedViews: [.sectionFooters]) {
          Section(footer: pinnedView) {
            ForEach(0..<selectedIndex, id: \.self) { index in
              previews[index]
                .frame(width: cameraPreviewSize, height: cameraPreviewSize)
                .border(Color.white, width: 1)
                .onTapGesture {
                  selectedIndex = index
                }
            }
            ForEach(selectedIndex+1..<previews.count, id: \.self) { index in
              previews[index]
                .frame(width: cameraPreviewSize, height: cameraPreviewSize)
                .border(Color.white, width: 1)
                .onTapGesture {
                  selectedIndex = index
                }
            }
          }

        }
        .frame(height: cameraPreviewSize)
      }
      previews[selectedIndex].frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  @State private var selectedIndex = 0
}

private let cameraPreviewSize = CGFloat(60)

#if DEBUG

struct SessionPreviewViewPreview: PreviewProvider {
  static var previews: some View {
    VStack {
      VStack {
        Text("Portrait")
        SessionPreviewView(previews: [
          Color.red.eraseToAnyView(),
          Color.green.eraseToAnyView(),
          Color.orange.eraseToAnyView(),
        ], pinnedView: Color.blue.eraseToAnyView())
      }
      .background(Color.black)
      .frame(width: 400, height: 700)
      VStack {
        Text("Landscape")
        SessionPreviewView(previews: [
          Color.red.eraseToAnyView(),
          Color.green.eraseToAnyView(),
          Color.orange.eraseToAnyView(),
        ], pinnedView: Color.blue.eraseToAnyView())
      }
      .background(Color.gray)
      .frame(width: 700, height: 400)
    }
    .previewLayout(.fixed(width: 700, height: 1100))
  }
}

#endif
