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
          ForEach(Resolution.known, id: \.self) {
            Text(language.resolution($0)).tag($0)
          }
        }
        .fieldValidation(hasError: viewStore.errorFields.contains(\.resolution))

        Picker(
          selection: viewStore.binding(\.$configuration.fps),
          label: Text(language.string(.fps))
        ) {
          ForEach(Array(0...120), id: \.self) {
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

      fovView
        .fieldValidation(hasError: viewStore.errorFields.contains(\.fov))
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

  private var fovView: some View {
    Section(header: Text(language.string(.fieldOfView))) {
      VStack(spacing: 0) {
        Text(language.fov(viewStore.configuration.fov))

        IntSlider(
          value: viewStore.binding(\.$configuration.fov),
          in: 0...120
        )
      }
    }
  }

  private var zoomView: some View {
    Section(header: Text(language.string(.zoom))) {
      VStack(spacing: 0) {
        Text(language.zoom(viewStore.configuration.zoom))

        Slider(value: viewStore.binding(\.$configuration.zoom), in: 0.1...2)
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
          in: 0...Int(upperBound)
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

struct DeviceCameraPreviews: PreviewProvider {
  static var previews: some View {
    DeviceCameraView(store: .init(initialState: .init(), reducer: deviceCameraReducer))
  }
}
