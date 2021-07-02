import SwiftUI
import CameraKit

struct SessionPressureView: View {
  let pressureLevel: CKPressureLevel
  let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

  var body: some View {
    let color: Color
    switch pressureLevel {
    case .nominal:
      color = .green
    case .serious:
      color = .orange
    case .shutdown:
      color = .red
    }
    return Rectangle()
      .foregroundColor(.black)
      .frame(width: 60, height: 60)
      .onReceive(timer) { _ in
        isVisible.toggle()
      }
      .overlay(
        RoundedRectangle(cornerRadius: 5)
          .foregroundColor(isVisible ? color : .clear)
          .frame(width: 20, height: 20)
      )

  }

  @State private var isVisible = true
}
