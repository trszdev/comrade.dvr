import Foundation
import SwiftUI
import Assets
import ComposableArchitecture
import DeviceState
import LocalizedUtils

public struct StartView: View {
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance
  @Environment(\.verticalSizeClass) var sizeClass
  @ObservedObject var viewStore: ViewStore<StartState, StartAction>

  public init(store: Store<StartState, StartAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    ZStack {
      appearance.color(.secondaryBackgroundColor)
        .edgesIgnoringSafeArea(.all)

      view
    }
    .onAppear {
      viewStore.send(.onAppear)
    }
    .onDisappear {
      viewStore.send(.onDisappear)
    }
  }

  private var view: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        ScrollView(.vertical, showsIndicators: false) {
          let numberOfColumns = Int(geometry.size.width / 160)
          LazyVGrid(
            columns: Array(repeating: 0, count: numberOfColumns).map { _ in .init(.flexible()) },
            spacing: 10
          ) {
            StartItemCameraView(shouldUpgrade: false, state: viewStore.backCameraState) {
              viewStore.send(.tapBackCamera)
            }

            StartItemCameraView(shouldUpgrade: !viewStore.isPremium, state: viewStore.frontCameraState) {
              viewStore.send(.tapFrontCamera)
            }
            .disabled(!viewStore.isPremium)

            StartItemMicrophoneView(state: viewStore.microphoneState) {
              viewStore.send(.tapMicrophone)
            }
          }
          .padding(10)
        }

        startButtonView
      }
      .navigationBarHidden(true)
    }
  }

  private var startButtonView: some View {
    let verticalSpacing: CGFloat = sizeClass == .compact ? 5 : 10
    return VStack(alignment: .leading, spacing: verticalSpacing) {
      HStack(spacing: 15) {
        appearance.image(.startIcon)
          .frame(width: 40)

        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Text(language.fullAppName())

            if viewStore.isPremium {
              Text(language.string(.pro))
                .foregroundColor(appearance.color(.proColor))
            }
          }

          Text(language.occupiedSpace(viewStore.localState.occupiedSpace))

          Text(language.lastCapture(viewStore.localState.lastCapture))
        }
        .font(.footnote)
        .foregroundColor(appearance.color(.textColorDisabled))
      }

      Button {
        viewStore.send(.start)
      } label: {
        RoundedRectangle(cornerRadius: 10)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .foregroundColor(.accentColor)
          .overlay(buttonOverlayView)
      }
      .disabled(viewStore.isLocked)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, verticalSpacing)
    .background(
      appearance.color(.mainBackgroundColor)
        .edgesIgnoringSafeArea(.all)
    )
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
}

struct StartPreviews: PreviewProvider {
  static var previews: some View {
    StartView(store: .init(initialState: .init(), reducer: startReducer, environment: .init()))
  }
}
