import Foundation
import SwiftUI
import Assets
import ComposableArchitecture
import Device

public struct StartView: View {
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance
  @ObservedObject var viewStore: ViewStore<StartState, StartAction>

  public init(store: Store<StartState, StartAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        ScrollView(.vertical, showsIndicators: false) {
          let numberOfColumns = Int(geometry.size.width / 160)
          LazyVGrid(
            columns: Array(repeating: 0, count: numberOfColumns).map { _ in .init(.flexible()) },
            spacing: 10
          ) {
            deviceCameraView(name: .backCamera, shouldUpgrade: false, state: viewStore.backCameraState) {
              viewStore.send(.tapBackCamera)
            }
            .aspectRatio(1, contentMode: .fit)

            deviceCameraView(
              name: .frontCamera,
              shouldUpgrade: !viewStore.isPremium,
              state: viewStore.frontCameraState
            ) {
              viewStore.send(.tapFrontCamera)
            }
            .aspectRatio(1, contentMode: .fit)

            deviceMicrophoneView {
              viewStore.send(.tapMicrophone)
            }
            .aspectRatio(1, contentMode: .fit)
          }
          .padding(10)
        }

        startButtonView
      }
      .navigationBarHidden(true)
    }
  }

  private var startButtonView: some View {
    Button {
      viewStore.send(.start)
    } label: {
      RoundedRectangle(cornerRadius: 10)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .foregroundColor(.accentColor)
        .overlay(buttonOverlayView)
    }
    .padding()
  }

  @ViewBuilder private var buttonOverlayView: some View {
    if let seconds = viewStore.state.localState.autostartSecondsRemaining {
      Text(language.format(.startingIn, arguments: "\(seconds)"))
        .foregroundColor(appearance.color(.mainBackgroundColor))
    } else {
      Text(language.string(.startRecording))
        .foregroundColor(appearance.color(.mainBackgroundColor))
    }
  }

  private func deviceCameraView(
    name: L10n,
    shouldUpgrade: Bool,
    state: DeviceCameraState,
    action: @escaping () -> Void
  ) -> some View {
    let enabled = !shouldUpgrade && state.enabled
    let opacity = shouldUpgrade ? 0.5 : 1
    let color = (enabled ? Color.accentColor : Color.gray).opacity(opacity)
    return Button(action: action) {
      RoundBorder(hasSpaces: !enabled)
        .stroke(lineWidth: 10)
        .padding(5)
        .foregroundColor(color)
        .overlay(
          VStack(alignment: .leading, spacing: 0) {
            Text(language.string(name))
              .fontWeight(.medium)
              .foregroundColor(color)
              .multilineTextAlignment(.leading)
              .lineSpacing(0)
              .lineLimit(2)
              .font(.title3)
              .padding(.bottom, 5)

            Text(language.resolution(state.configuration.resolution))

            Text(language.fps(state.configuration.fps))

            Text(language.quality(state.configuration.quality))

            Spacer()

            HStack {
              if shouldUpgrade {
                Text(language.string(.pro))
                  .foregroundColor(appearance.color(.proColor))
              }

              Spacer()

              Image(systemName: "camera")
                .foregroundColor(color)
            }
          }
          .padding(15)
          .font(.callout)
          .minimumScaleFactor(0.5)
          .foregroundColor(
            appearance.color(.textColorDisabled)
              .opacity(opacity)
          )
        )
    }
  }

  private func deviceMicrophoneView(action: @escaping () -> Void) -> some View {
    let enabled = viewStore.microphoneState.enabled
    let color: Color = enabled ? .accentColor : .gray
    return Button(action: action) {
      RoundBorder(hasSpaces: !enabled)
        .stroke(lineWidth: 10)
        .padding(5)
        .foregroundColor(color)
        .overlay(
          VStack(alignment: .leading, spacing: 0) {
            Text(language.string(.microphone))
              .fontWeight(.medium)
              .foregroundColor(color)
              .multilineTextAlignment(.leading)
              .lineSpacing(0)
              .lineLimit(2)
              .font(.title3)
              .padding(.bottom, 5)

            Text(language.polarPattern(viewStore.microphoneState.configuration.polarPattern))

            Text(language.quality(viewStore.microphoneState.configuration.quality))

            Spacer()

            HStack {
              Spacer()

              Image(systemName: "mic")
                .foregroundColor(color)
            }
          }
          .padding(15)
          .font(.callout)
          .minimumScaleFactor(0.5)
          .foregroundColor(appearance.color(.textColorDisabled))
        )
    }
  }
}

struct StartPreviews: PreviewProvider {
  static var previews: some View {
    StartView(store: .init(initialState: .init(), reducer: startReducer, environment: .init()))
  }
}

private struct RoundBorder: Shape {
  var hasSpaces = true

  func path(in rect: CGRect) -> Path {
    var path = Path()

    let points = self.points(in: rect)
    if !hasSpaces {
      path.move(to: points[0].0)
    }
    for (pt1, pt2, corner, pt3, pt4) in points {
      if hasSpaces {
        path.move(to: pt1)
      } else {
        path.addLine(to: pt1)
      }
      path.addLine(to: pt2)
      path.addCurve(to: pt3, control1: corner, control2: corner)
      if hasSpaces {
        path.addLine(to: pt4)
      }
    }
    if !hasSpaces {
      path.addLine(to: points[0].0)
    }
    return path
  }

  // swiftlint:disable large_tuple
  private func points(in rect: CGRect) -> [(CGPoint, CGPoint, CGPoint, CGPoint, CGPoint)] {
    let sideLength = rect.width / 3
    let sideRemaining = rect.width - sideLength
    let length = rect.width / 6
    let remaining = rect.width - length
    let width = rect.width
    return [
      (
        CGPoint(x: 0, y: sideLength),
        CGPoint(x: 0, y: length),
        CGPoint(x: 0, y: 0),
        CGPoint(x: length, y: 0),
        CGPoint(x: sideLength, y: 0)
      ),
      (
        CGPoint(x: sideRemaining, y: 0),
        CGPoint(x: remaining, y: 0),
        CGPoint(x: width, y: 0),
        CGPoint(x: width, y: length),
        CGPoint(x: width, y: sideLength)
      ),
      (
        CGPoint(x: width, y: sideRemaining),
        CGPoint(x: width, y: remaining),
        CGPoint(x: width, y: width),
        CGPoint(x: remaining, y: width),
        CGPoint(x: sideRemaining, y: width)
      ),
      (
        CGPoint(x: sideLength, y: width),
        CGPoint(x: length, y: width),
        CGPoint(x: 0, y: width),
        CGPoint(x: 0, y: remaining),
        CGPoint(x: 0, y: sideRemaining)
      ),
    ]
  }
}
