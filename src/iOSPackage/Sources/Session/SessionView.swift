import SwiftUI
import ComposableArchitecture
import LocalizedUtils
import Assets
import CommonUI

public struct SessionView: View {
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance
  @ObservedObject var viewStore: ViewStore<SessionState, SessionAction>

  public init(store: Store<SessionState, SessionAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    Color.black
      .ignoresSafeArea()
      .overlay(mainVideoView)
      .overlay(viewStore.state.hasTwoCameras ? secondaryVideoView : nil, alignment: secondaryVideoAlignment)
      .overlay(backButtonView, alignment: stopButtonAlignment)
      .alert(item: viewStore.binding(\.$localState.alertError)) { error in
        Alert(
          title: Text(language.string(.error)),
          message: Text(language.errorMessage(error)),
          dismissButton: .cancel(Text(language.string(.ok)))
        )
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
      .onDisappear {
        viewStore.send(.onDisappear)
      }
  }

  private var stopButtonAlignment: Alignment {
    switch viewStore.orientation {
    case .landscapeLeft:
      return .trailing
    case .landscapeRight:
      return .leading
    case .portrait:
      return .bottom
    case .portraitUpsideDown:
      return .top
    }
  }

  private var secondaryVideoAlignment: Alignment {
    switch viewStore.orientation {
    case .landscapeLeft:
      return .topLeading
    case .landscapeRight:
      return .topTrailing
    case .portrait:
      return .topTrailing
    case .portraitUpsideDown:
      return .bottomLeading
    }
  }

  private var secondaryVideoView: some View {
    let view = viewStore.secondaryCameraPreviewView.map(UIViewRepresentableView.init)

    return Button {
      viewStore.send(.switchCameras)
    } label: {
      Color.white
        .frame(width: 150, height: 150)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
          view?
            .cornerRadius(10)
            .padding(8)
        )
    }
    .padding()
  }

  @ViewBuilder private var mainVideoView: some View {
    if let view = viewStore.mainCameraPreviewView {
      UIViewRepresentableView(view: view)
    }
  }

  private var backButtonView: some View {
    Button {
      viewStore.send(.tapBack)
    } label: {
      appearance.color(.textColorDestructive)
        .frame(width: 45, height: 45)
        .cornerRadius(5)
    }
    .buttonStyle(StopButtonStyle())
  }
}

private struct StopButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    let scale: CGFloat = configuration.isPressed ? 1.1 : 1

    Circle()
      .foregroundColor(.white)
      .frame(width: 80, height: 80)
      .shadow(radius: 5)
      .overlay(
        configuration.label
          .scaleEffect(x: scale, y: scale)
          .animation(.default, value: configuration.isPressed)
      )
  }
}

@available(iOS 15.0, *)
struct SessionViewPreviews: PreviewProvider {
  static var previews: some View {
    SessionView(store: .init(
      initialState: .init(
        backCameraPreviewView: .colored(.orange),
        frontCameraPreviewView: .colored(.green),
        orientation: .portrait
      ),
      reducer: sessionReducer,
      environment: .init())
    )
    .previewInterfaceOrientation(.portrait)
  }
}

private extension UIView {
  static func colored(_ color: UIColor) -> UIView {
    let previewView = UIView()
    previewView.backgroundColor = color
    return previewView
  }
}
