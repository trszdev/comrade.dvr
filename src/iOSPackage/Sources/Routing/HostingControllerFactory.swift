import SwiftUI
import Assets
import Util
import Combine

final class HostingObject: ObservableObject {
  @Published var language: Language?
  @Published var appearance: Appearance?

  init(appearancePublisher: CurrentValuePublisher<Appearance?>, languagePublisher: CurrentValuePublisher<Language?>) {
    language = languagePublisher.currentValue()
    appearance = appearancePublisher.currentValue()
    languagePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] language in
        self?.language = language
      }
      .store(in: &cancellables)
    appearancePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] appearance in
        self?.appearance = appearance
      }
      .store(in: &cancellables)
  }

  private var cancellables = Set<AnyCancellable>()
}

struct HostingView<Content: View>: View {
  @ObservedObject var hostingObject: HostingObject
  @ViewBuilder var content: () -> Content

  var body: some View {
    content()
      .environment(\.language, hostingObject.language)
      .environment(\.appearance, hostingObject.appearance)
  }
}

struct HostingControllerFactory {
  var hostingObject: HostingObject

  func hostingController<Content: View>(rootView: Content) -> UIHostingController<HostingView<Content>> {
    let view = HostingView(hostingObject: hostingObject) { rootView }
    return UIHostingController(rootView: view)
  }
}
