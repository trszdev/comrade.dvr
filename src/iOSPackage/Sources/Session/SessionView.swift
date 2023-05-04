import SwiftUI
import ComposableArchitecture
import LocalizedUtils
import Assets
import CameraKit
import CommonUI

public struct SessionView: View {
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance
  @ObservedObject var viewStore: ViewStore<SessionState, SessionAction>

  public init(store: Store<SessionState, SessionAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    mainVideoView
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
      return .leading
    case .landscapeRight:
      return .trailing
    case .portrait:
      return .bottom
    case .portraitUpsideDown:
      return .top
    }
  }

  private var secondaryVideoAlignment: Alignment {
    switch viewStore.orientation {
    case .landscapeLeft:
      return .topTrailing
    case .landscapeRight:
      return .topLeading
    case .portrait:
      return .topTrailing
    case .portraitUpsideDown:
      return .bottomLeading
    }
  }

  private var secondaryVideoView: some View {
    Button {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      viewStore.send(.switchCameras)
    } label: {
      Color.white
        .frame(width: 150, height: 150)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
          viewStore.secondaryCameraPreviewView.flatMap(UIViewRepresentableView.init)?
            .frame(maxWidth: .infinity)
            .background(Color.gray)
            .cornerRadius(10)
            .padding(8)
        )
    }
    .simultaneousGesture(LongPressGesture(minimumDuration: 0).onEnded { _ in
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
    })
    .padding()
  }

  private var mainVideoView: some View {
    GeometryReader { geometry in
      ZStack(alignment: .top) {
        if let view = viewStore.mainCameraPreviewView {
          UIViewRepresentableView(view: view)
        } else {
          Color.black
        }

        Color.black
          .opacity(0.5)
          .frame(height: geometry.safeAreaInsets.top)
      }
      .ignoresSafeArea()
    }
  }

  private var backButtonView: some View {
    Button {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      viewStore.send(.tapBack)
    } label: {
      appearance.color(.textColorDestructive)
        .frame(width: 45, height: 45)
        .cornerRadius(5)
    }
    .simultaneousGesture(LongPressGesture(minimumDuration: 0).onEnded { _ in
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
    })
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
    let view = UIView()
    view.backgroundColor = color
    return view
  }
}
