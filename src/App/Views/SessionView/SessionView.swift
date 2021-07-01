import SwiftUI
import Combine

struct SessionViewBuilder {
  let haptics: Haptics

  func makeView<ViewModel: SessionViewModel>(viewModel: ViewModel) -> AnyView {
    SessionViewPortrait(viewModel: viewModel, haptics: haptics).eraseToAnyView()
  }
}

struct SessionViewPortrait<ViewModel: SessionViewModel>: View {
  @ObservedObject var viewModel: ViewModel
  @Environment(\.appLocale) var appLocale: AppLocale
  let haptics: Haptics

  var body: some View {
    VStack {
      viewModel.previews.isEmpty ?
        Color.clear.eraseToAnyView() :
        SessionPreviewView(previews: viewModel.previews).eraseToAnyView()
      HStack(spacing: 30) {
        bottomButtonView(content: infoButtonView)
        bottomButtonView(content: stopButtonView)
        bottomButtonView(content: microphoneButtonView)
      }
    }
    .background(Color.black.ignoresSafeArea())
    .overlay(
      ZStack(alignment: .top) {
        infoView
        notificationView
      }
    )
    .onReceive(viewModel.dismissAlertPublisher) {
      isNotificationVisible = false
    }
    .onChange(of: isHovered) { isHovered in
      guard isHovered else { return }
      haptics.hover()
    }
  }

  private var infoView: some View {
    ZStack(alignment: .topTrailing) {
      blurView
      InfoTextView(text: viewModel.infoText)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .animation(nil)
      Image(sfSymbol: .cross)
        .fitResizable
        .padding()
        .frame(width: 50, height: 50)
        .background(Color.clear.contentShape(Rectangle()))
        .foregroundColor(.white)
        .onTapGesture {
          isInfoTextVisible = false
        }
    }
    .padding()
    .opacity(isInfoTextVisible ? 1 : 0)
    .defaultAnimation
  }

  private var notificationView: some View {
    Text(notificationText)
      .foregroundColor(notificationTextColor)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
      .background(blurView)
      .offset(x: 0, y: 70)
      .onTapGesture {
        isNotificationVisible = false
      }
      .animation(nil)
      .opacity(isNotificationVisible ? 1 : 0)
      .defaultAnimation
  }

  private var blurView: VisualEffectView {
    VisualEffectView(effect: UIBlurEffect(style: .dark))
  }

  private func bottomButtonView<Content: View>(content: Content) -> some View {
    content
      .onTapGesture {
        showNotification(text: appLocale.pressButtonTwiceString)
        haptics.warn()
      }
      .simultaneousGesture(HoverGesture.bind($isHovered))
  }

  private var stopButtonView: some View {
    RoundedRectangle(cornerRadius: 5)
      .foregroundColor(.red)
      .frame(width: 60, height: 60)
      .overlay(Text("STOP").foregroundColor(.white))
      .onTapGesture(count: 2) {
        isNotificationVisible = false
        haptics.success()
        viewModel.stopSession()
      }
  }

  private var microphoneButtonView: some View {
    Image(sfSymbol: .mic)
      .fitResizable
      .foregroundColor(.white)
      .padding(9)
      .frame(width: 60, height: 60)
      .shadow(color: .white, radius: 3)
      .if(viewModel.microphoneMuted) { view in
        view.overlay(Image(sfSymbol: .cross).fitResizable.padding(8).foregroundColor(.red))
      }
      .onTapGesture(count: 2) {
        viewModel.microphoneMuted.toggle()
        showNotification(text: viewModel.microphoneMuted ?
          appLocale.microphoneMutedString :
          appLocale.microphoneUnmutedString
        )
        haptics.success()
      }
  }

  private var infoButtonView: some View {
    Image(sfSymbol: .info)
      .fitResizable
      .foregroundColor(.white)
      .padding(8)
      .frame(width: 60, height: 60)
      .shadow(color: .white, radius: 3)
      .onTapGesture(count: 2) {
        showInfo()
        isNotificationVisible = false
        haptics.success()
      }
  }

  private func showNotification(text: String) {
    viewModel.scheduleDismissAlertTimer()
    notificationText = text
    isNotificationVisible = true
  }

  private func showInfo() {
    isInfoTextVisible = true
  }

  @State private var isHovered = false
  @State private var isNotificationVisible = false
  @State private var notificationText = ""
  @State private var isInfoTextVisible = false
}

private let notificationTextColor = Color(white: 0.8)

private struct InfoTextView: UIViewRepresentable {
  let text: String

  func makeUIView(context: Context) -> UITextView {
    let view = UITextView()
    view.isScrollEnabled = true
    view.scrollsToTop = true
    view.isEditable = false
    view.isUserInteractionEnabled = true
    view.text = text
    view.backgroundColor = .clear
    view.textColor = UIColor(notificationTextColor)
    return view
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
  }
}

#if DEBUG

struct SessionViewPreviews: PreviewProvider {
  static var previews: some View {
    locator.resolve(SessionViewBuilder.self).makeView(viewModel: locator.resolve(SessionViewModelImpl.self))
  }
}

#endif
