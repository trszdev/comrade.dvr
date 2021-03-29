import SwiftUI
import CameraKit

struct CameraKitView: View {
  let session: CKSession!

  var body: some View {
    HStack {
      session.cameras.values.first!.previewView
    }
  }
}

struct CameraKitViewPreview: PreviewProvider {
  static var previews: some View {
    CameraKitView(session: nil)
  }
}
