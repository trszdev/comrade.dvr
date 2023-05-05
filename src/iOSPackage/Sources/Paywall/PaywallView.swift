import SwiftUI
import Assets
import ComposableArchitecture
import ComposableArchitectureExtensions

public struct PaywallView: View {
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance
  @ObservedObject var viewStore: ViewStore<PaywallState, PaywallAction>

  public init(store: Store<PaywallState, PaywallAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(language.appName())

        Text(language.string(.pro))
          .foregroundColor(appearance.color(.proColor))
      }
      .font(.title)
      .padding(.bottom, 10)

      VStack(alignment: .leading) {
        // Text(language.string(.paywallFeature1))
        Text(language.string(.paywallFeature2))
        Text(language.string(.paywallFeature3))
        Text(language.string(.paywallFeature4))
        Text(language.string(.paywallFeature5))
      }
      .foregroundColor(appearance.color(.textColorDefault))
      .padding(.bottom, 20)

      Button {
        viewStore.send(.tapSubscribe)
      } label: {
        RoundedRectangle(cornerRadius: 10)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .foregroundColor(.accentColor)
          .overlay(
            Text(language.string(.continue))
              .foregroundColor(appearance.color(.mainBackgroundColor))
          )
      }
      .padding(.bottom, 5)

      HStack {
        Spacer()
        Button {
          viewStore.send(.tapRules)
        } label: {
          Text("Terms & conditions")
        }

        Text("•")

        Button {
          viewStore.send(.tapRestore)
        } label: {
          Text("Restore")
        }

        Spacer()
      }
      .font(.caption)
      .foregroundColor(appearance.color(.textColorDefault))
    }
    .padding()
  }
}

#if DEBUG
struct PaywallViewPreviews: PreviewProvider {
  static var previews: some View {
    PaywallView(store: paywallReducer.store(initialState: .init()))
  }
}
#endif
