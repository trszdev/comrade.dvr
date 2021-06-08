import SwiftUI

protocol ModalViewPresenter: ViewPresenter {
}

struct ModalViewPresenterImpl: ModalViewPresenter {
  func presentView<Content>(animated: Bool, @ViewBuilder content: @escaping () -> Content) where Content: View {
    guard let modalView = content() as? ModalView else { return }
    let hostingVc = UIHostingController(rootView: modalView)
    hostingVc.view.backgroundColor = .clear
    hostingVc.modalPresentationStyle = .overCurrentContext
    modalView.hostingVc.value = hostingVc
    guard let topViewController = UIApplication.shared.windows.first?.topViewController else { return }
    topViewController.present(hostingVc, animated: false, completion: nil)
  }

  func presentViewController(animated: Bool, viewController: UIViewController) {
    notImplemented()
  }
}

struct ModalView: View {
  init<Content: View>(
    isVisible: Bool = false,
    onSubmit: @escaping () -> Void = {},
    @ViewBuilder content: () -> Content
  ) {
    self.content = content().eraseToAnyView()
    self.onSubmit = onSubmit
    self.opacity = isVisible ? 1 : 0
    self.isVisible = isVisible
  }

  @Environment(\.appLocale) var appLocale: AppLocale

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea().opacity(opacity * 0.4)
      modalBody
        .environment(\.colorScheme, .light)
        .environment(\.theme, WhiteTheme())
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
      content
      Divider().background(Color.clear)
      HStack(spacing: 0) {
        buttonView(text: Text(appLocale.cancelString).bold(), action: close)
        Divider().background(Color.clear)
        buttonView(text: Text(appLocale.okString), action: {
          self.close()
          self.onSubmit()
        })
      }
      .frame(height: 45)
    }
    .frame(width: 275)
    .background(VisualEffectView(effect: UIBlurEffect(style: .extraLight)))
    .cornerRadius(15)
  }

  private func close() {
    withAnimation(.linear(duration: 0.15)) {
      isVisible = false
      opacity = 0
      scaleMultiplier = 1
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
      self.hostingVc.value?.dismiss(animated: false, completion: nil)
    }
  }

  private func buttonView(text: Text, action: @escaping () -> Void) -> some View {
    Button(action: action, label: { text })
      .buttonStyle(ModalViewButtonStyle())
  }

  fileprivate let hostingVc = WeakRef<UIViewController>()
  @State private var isVisible = false
  @State private var opacity = 1.0
  @State private var scaleMultiplier: CGFloat = 1.0
  private let content: AnyView
  private let onSubmit: () -> Void
}

private struct ModalViewButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      configuration.isPressed ?
        VisualEffectView(effect: UIBlurEffect(style: .dark)).opacity(0.15).eraseToAnyView() :
        Color.clear.contentShape(Rectangle()).eraseToAnyView()
      configuration.label.foregroundColor(.accentColor)
    }
  }
}

#if DEBUG

struct ModalViewPreview: PreviewProvider {
  static var previews: some View {
    VStack(alignment: .leading, spacing: 10) {
      VStack(spacing: 0) {
        Text("Original alert controller")
        PreviewUIAlertView()
      }
      .frame(height: 200)
      VStack(spacing: 0) {
        Text("Custom alert controller")
        previewModal
      }
      .frame(width: 275, height: 200)
    }
    .background(Color.green)
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
