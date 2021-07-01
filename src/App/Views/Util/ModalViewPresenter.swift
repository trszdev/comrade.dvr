import SwiftUI
import Combine

protocol ModalViewPresenter: ViewPresenter {
  var submitPublisher: AnyPublisher<Void, Never> { get }
  var cancelPublisher: AnyPublisher<Void, Never> { get }
  func updateModal()
}

final class ModalViewPresenterImpl: ModalViewPresenter {
  init(application: UIApplication) {
    self.application = application
  }

  func presentView<Content>(animated: Bool, @ViewBuilder content: @escaping () -> Content) where Content: View {
    let observableUnit = ObservableUnit()
    let modalView = ModalView(
      onSubmit: onSubmit,
      onCancel: onCancel,
      observableUnit: observableUnit,
      content: content
    )
    let hostingVc = UIHostingController(rootView: modalView)
    hostingVc.view.backgroundColor = .clear
    hostingVc.modalPresentationStyle = .overFullScreen
    guard let topViewController = application.windows.first?.topViewController else { return }
    self.hostingVc = hostingVc
    self.observableUnit = observableUnit
    topViewController.present(hostingVc, animated: false, completion: nil)
  }

  func presentViewController(animated: Bool, viewController: UIViewController) {
    notImplemented()
  }

  var submitPublisher: AnyPublisher<Void, Never> { submitPublisherInternal.eraseToAnyPublisher() }
  var cancelPublisher: AnyPublisher<Void, Never> { cancelPublisherInternal.eraseToAnyPublisher() }

  func updateModal() {
    observableUnit?.update()
  }

  private func onSubmit() {
    submitPublisherInternal.send()
    dismissVc()
  }

  private func onCancel() {
    cancelPublisherInternal.send()
    dismissVc()
  }

  private func dismissVc() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
      self?.hostingVc?.dismiss(animated: false, completion: nil)
    }
  }

  private let application: UIApplication
  private let submitPublisherInternal = PassthroughSubject<Void, Never>()
  private let cancelPublisherInternal = PassthroughSubject<Void, Never>()
  private weak var hostingVc: UIViewController?
  private weak var observableUnit: ObservableUnit?
}

struct ModalView: View {
  init<Content: View>(
    isVisible: Bool = false,
    onSubmit: @escaping () -> Void = {},
    onCancel: @escaping () -> Void = {},
    observableUnit: ObservableUnit = ObservableUnit(),
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.onSubmit = onSubmit
    self.onCancel = onCancel
    self._observableUnit = StateObject(wrappedValue: observableUnit)
    self.content = { content().eraseToAnyView() }
    self.opacity = isVisible ? 1 : 0
    self.isVisible = isVisible
  }

  @Environment(\.appLocale) var appLocale: AppLocale
  @Environment(\.colorScheme) var colorScheme: ColorScheme

  var body: some View {
    ZStack {
      smokeColor.ignoresSafeArea().opacity(opacity * 0.2)
      modalBody
        .allowsHitTesting(isVisible)
        .scaleEffect(scaleMultiplier)
        .opacity(opacity)
    }
    .defaultAnimation
    .onAppear {
      scaleMultiplier = 1.2
      opacity = 0
      withAnimation(.linear(duration: 0.15)) {
        isVisible = true
        opacity = 1
        scaleMultiplier = 1
      }
    }
  }

  private var modalBody: some View {
    VStack(spacing: 0) {
      content()
      dividerView
      HStack(spacing: 0) {
        buttonView(text: Text(appLocale.cancelString).bold(), action: {
          close()
          onCancel()
        })
        dividerView
        buttonView(text: Text(appLocale.okString), action: {
          close()
          onSubmit()
        })
      }
      .frame(height: 45)
    }
    .frame(width: 270)
    .background(VisualEffectView(isDark: isDark))
    .cornerRadius(15)
  }

  private var isDark: Bool {
    colorScheme == .dark
  }

  private var smokeColor: Color {
    isDark ? .clear : .black
  }

  private var dividerView: some View {
    Divider().background(isDark ? Color.white : Color.clear)
  }

  private func close() {
    withAnimation(.linear(duration: 0.15)) {
      isVisible = false
      opacity = 0
      scaleMultiplier = 1
    }
  }

  private func buttonView(text: Text, action: @escaping () -> Void) -> some View {
    Button(
      action: action,
      label: { text.frame(maxWidth: .infinity).padding(12) }
    )
    .buttonStyle(ModalViewButtonStyle(isDark: isDark))
  }

  @StateObject private var observableUnit: ObservableUnit
  @State private var isVisible = false
  @State private var opacity = 1.0
  @State private var scaleMultiplier: CGFloat = 1.0
  private let content: () -> AnyView
  private let onSubmit: () -> Void
  private let onCancel: () -> Void
}

private extension VisualEffectView {
  init(isDark: Bool) {
    self.init(effect: UIBlurEffect(style: isDark ? .dark : .extraLight))
  }
}

struct ModalViewButtonStyle: ButtonStyle {
  var isDark = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label.foregroundColor(.accentColor).background(
      configuration.isPressed ?
        VisualEffectView(isDark: !isDark).opacity(0.15).eraseToAnyView() :
        Color.clear.contentShape(Rectangle()).eraseToAnyView()
    )
  }
}

#if DEBUG

struct ModalViewPreview: PreviewProvider {
  static var previews: some View {
    HStack(spacing: 0) {
      colorSchemePreview(.light)
      colorSchemePreview(.dark)
    }.previewLayout(.fixed(width: 600, height: 500))
  }

  private static func colorSchemePreview(_ colorScheme: ColorScheme) -> some View {
    VStack(alignment: .leading, spacing: 15) {
      VStack(spacing: 0) {
        Text("Original alert controller")
        PreviewUIAlertView()
      }
      .frame(height: 170)
      VStack(spacing: 0) {
        Text("Custom alert controller")
        previewModal
      }
      .frame(height: 170)
    }
    .frame(width: 275)
    .background(Color.green)
    .environment(\.colorScheme, colorScheme)
  }

  private static var previewModal: some View {
    ModalView(isVisible: true) {
      VStack(spacing: 4) {
        Text("Alert").bold()
        Text("Message").font(.footnote)
      }
      .padding(.vertical, 18)
      .padding(.horizontal, 10)
    }
  }

  private struct PreviewUIAlertView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIAlertController, context: Context) {
    }

    func makeUIViewController(context: Context) -> UIAlertController {
      let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      return alert
    }
  }
}

#endif
