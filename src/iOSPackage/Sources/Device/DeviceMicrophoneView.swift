import SwiftUI
import ComposableArchitecture
import ComposableArchitectureExtensions

public struct DeviceMicrophoneView: View {
  @Environment(\.language) var language
  @ObservedObject var viewStore: ViewStore<DeviceMicrophoneState, DeviceMicrophoneAction>

  public init(store: Store<DeviceMicrophoneState, DeviceMicrophoneAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    Form {
      Section {
        Toggle(isOn: viewStore.binding(\.$enabled)) {
          Text(language.string(.deviceEnabled))
        }
      }

      Section {
        Picker(
          selection: viewStore.binding(\.$configuration.quality),
          label: Text(language.string(.quality))
        ) {
          ForEach(Quality.allCases, id: \.self) {
            Text(language.quality($0)).tag($0)
          }
        }

        Picker(
          selection: viewStore.binding(\.$configuration.polarPattern),
          label: Text(language.string(.polarPattern))
        ) {
          ForEach(PolarPattern.allCases, id: \.self) {
            Text(language.polarPattern($0)).tag($0)
          }
        }
      }
    }
  }
}

struct DeviceMicrophonePreviews: PreviewProvider {
  static var previews: some View {
    DeviceMicrophoneView(store: .init(initialState: .init(), reducer: deviceMicrophoneReducer))
  }
}
