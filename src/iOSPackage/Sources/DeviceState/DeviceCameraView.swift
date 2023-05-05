import SwiftUI
import ComposableArchitecture
import CommonUI
import Device

public struct DeviceCameraView: View {
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance
  @ObservedObject var viewStore: ViewStore<DeviceCameraState, DeviceCameraAction>

  public init(store: Store<DeviceCameraState, DeviceCameraAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    Form {
      Section {
        Toggle(isOn: viewStore.binding(\.$enabled)) {
          Text(language.string(.deviceEnabled))
        }
      }
      .disabled(viewStore.isLocked)

      Section {
        Picker(
          selection: viewStore.binding(\.$configuration.resolution),
          label: Text(language.string(.resolution))
        ) {
          ForEach(viewStore.index.resolutions, id: \.self) {
            Text(language.resolution($0)).tag($0)
          }
        }
        .fieldValidation(hasError: viewStore.errorFields.contains(\.resolution))

        Picker(
          selection: viewStore.binding(\.$configuration.fov),
          label: Text(language.string(.fieldOfView))
        ) {
          ForEach(viewStore.fovIndex.fovs, id: \.self) {
            Text(language.fov($0)).tag($0)
          }
        }
        .fieldValidation(hasError: viewStore.errorFields.contains(\.fov))

        Picker(
          selection: viewStore.binding(\.$configuration.fps),
          label: Text(language.string(.fps))
        ) {
          ForEach(viewStore.fpsAndZoom.fps, id: \.self) {
            Text(language.fps($0)).tag($0)
          }
        }
        .fieldValidation(hasError: viewStore.errorFields.contains(\.fps))

        Picker(
          selection: viewStore.binding(\.$configuration.quality),
          label: Text(language.string(.quality))
        ) {
          ForEach(Quality.allCases, id: \.self) {
            Text(language.quality($0)).tag($0)
          }
        }
        .fieldValidation(hasError: viewStore.errorFields.contains(\.quality))
      }
      .disabled(!viewStore.enabled || viewStore.isLocked)

      bitrateView
        .fieldValidation(hasError: viewStore.errorFields.contains(\.bitrate))
        .disabled(!viewStore.enabled || viewStore.isLocked)

      useH265View
        .fieldValidation(hasError: viewStore.errorFields.contains(\.useH265))
        .disabled(!viewStore.enabled || viewStore.isLocked)

      zoomView
        .fieldValidation(hasError: viewStore.errorFields.contains(\.zoom))
        .disabled(!viewStore.enabled || viewStore.isLocked)
    }
    .toolbar {
      DeviceToolbarView(
        hasErrors: viewStore.hasErrors,
        isLoading: viewStore.isLocked,
        title: viewStore.deviceName,
        showAlert: viewStore.binding(\.$showAlert)
      )
    }
  }

  private var useH265View: some View {
    Section {
      Toggle(isOn: viewStore.binding(\.$configuration.useH265)) {
        Text(language.string(.useH265))
      }
    }
  }

  private var zoomView: some View {
    Section(header: Text(language.string(.zoom))) {
      VStack(spacing: 0) {
        Text(language.zoom(viewStore.configuration.zoom))

        Slider(
          value: viewStore.binding(\.$configuration.zoom),
          in: viewStore.fpsAndZoom.zoom
        )
      }
    }
  }

  private var bitrateView: some View {
    Section(header: Text(language.string(.bitrate))) {
      let max = BitrateSuggestion.all[viewStore.configuration.resolution]?.last?.bitrate
      let upperBound = Double((max ?? BitrateSuggestion.p2160.last!.bitrate).bitsPerSecond) * 1.5
      VStack(spacing: 0) {
        Text(language.bitrate(viewStore.configuration.bitrate))

        IntSlider(
          value: viewStore.binding(\.$configuration.bitrate.bitsPerSecond),
          in: 1...Int(upperBound)
        )
      }

      ForEach(BitrateSuggestion.all[viewStore.configuration.resolution] ?? []) { bitrateSuggestion in
        Button {
          viewStore.send(.setBitrate(bitrateSuggestion.bitrate))
        } label: {
          HStack {
            Spacer()

            Text(bitrateSuggestion.description)

            Spacer()
          }
        }
      }
    }
  }
}

#if DEBUG
struct DeviceCameraPreviews: PreviewProvider {
  static var previews: some View {
    DeviceCameraView(
      store: .init(
        initialState: .init(),
        reducer: deviceCameraReducer,
        environment: .init()
      )
    )
  }
}
#endif
