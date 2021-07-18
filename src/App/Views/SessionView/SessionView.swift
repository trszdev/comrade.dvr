import SwiftUI
import Combine
import CameraKit
import AutocontainerKit

final class SessionViewBuilder: AKBuilder {
  func makeView<ViewModel: SessionViewModel>(
    viewModel: ViewModel,
    orientation: CKOrientation
  ) -> AnyView {
    SessionView(
      viewModel: viewModel,
      haptics: resolve(Haptics.self),
      mediaChunkRepository: resolve(MediaChunkRepository.self),
      orientation: orientation
    )
    .eraseToAnyView()
  }
}

struct SessionView<ViewModel: SessionViewModel>: View {
  @ObservedObject var viewModel: ViewModel
  @Environment(\.appLocale) var appLocale: AppLocale
  let haptics: Haptics
  let mediaChunkRepository: MediaChunkRepository
  let orientation: CKOrientation

  var body: some View {
    orientedBody
    .onReceive(viewModel.dismissAlertPublisher) {
      isNotificationVisible = false
    }
    .onChange(of: viewModel.pressureLevel) { pressureLevel in
      showNotification(text: appLocale.pressureLevelAlertText(pressureLevel))
    }
    .onReceive(viewModel.errorPublisher) { error in
      self.error = error
      showAlert = true
    }
    .onReceive(mediaChunkRepository.errorPublisher) { error in
      self.error = error
      showAlert = true
    }
    .alert(isPresented: $showAlert, content: alertContent)
    .onChange(of: isHovered) { isHovered in
      guard isHovered else { return }
      haptics.hover()
    }
  }

  private func alertContent() -> Alert {
    guard let error = error else { return Alert(title: Text("")) }
    return Alert(
      title: Text(appLocale.errorString),
      message: Text(appLocale.errorBody(error)),
      dismissButton: .cancel(viewModel.stopSession)
    )
  }

  private var orientedBody: AnyView {
    switch orientation {
    case .landscapeLeft, .landscapeRight:
      return landscapeBody.eraseToAnyView()
    case .portrait, .portraitUpsideDown:
      return portraitBody.eraseToAnyView()
    }
  }

  private var portraitBody: some View {
    VStack {
      viewModel.previews.isEmpty ?
        Color.clear.eraseToAnyView() :
        SessionPreviewView(
          previews: viewModel.previews,
          pinnedView: pressureView,
          orientation: orientation
        )
        .eraseToAnyView()
      HStack(spacing: 30) {
        bottomButtonView(content: infoButtonView)
        bottomButtonView(content: stopButtonView)
        bottomButtonView(content: microphoneButtonView)
      }
    }
    .background(Color.black.ignoresSafeArea())
    .overlay(
      ZStack(alignment: .top) {
        SessionInfoView(text: viewModel.infoText, isVisible: $isInfoTextVisible)
        SessionNotificationView(text: notificationText, isVisible: $isNotificationVisible)
      }
    )
  }

  private var landscapeBody: some View {
    HStack {
      viewModel.previews.isEmpty ?
        Color.clear.eraseToAnyView() :
        SessionPreviewView(
          previews: viewModel.previews,
          pinnedView: pressureView,
          orientation: orientation
        )
        .eraseToAnyView()
      VStack(spacing: 30) {
        bottomButtonView(content: infoButtonView)
        bottomButtonView(content: stopButtonView)
        bottomButtonView(content: microphoneButtonView)
      }
    }
    .background(Color.black.ignoresSafeArea())
    .overlay(
      ZStack(alignment: .top) {
        SessionInfoView(text: viewModel.infoText, isVisible: $isInfoTextVisible)
        SessionNotificationView(text: notificationText, isVisible: $isNotificationVisible)
      }
    )
  }

  private var pressureView: AnyView {
    SessionPressureView(pressureLevel: viewModel.pressureLevel)
      .onTapGesture {
        haptics.success()
        showNotification(text: appLocale.pressureLevelAlertText(viewModel.pressureLevel))
      }
      .eraseToAnyView()
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
      .allowsHitTesting(viewModel.microphoneEnabled)
      .opacity(viewModel.microphoneEnabled ? 1 : 0)
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

  @State private var showAlert = false
  @State private var error: Error?
  @State private var isHovered = false
  @State private var isNotificationVisible = false
  @State private var notificationText = ""
  @State private var isInfoTextVisible = false
}

#if DEBUG

struct SessionViewPreviews: PreviewProvider {
  static var previews: some View {
    let viewModel = locator.resolve(SessionViewModelBuilder.self).makeViewModel()
    locator.resolve(SessionViewBuilder.self).makeView(viewModel: viewModel, orientation: .portrait)
    locator.resolve(SessionViewBuilder.self).makeView(viewModel: viewModel, orientation: .landscapeRight)
    locator.resolve(SessionViewBuilder.self).makeView(viewModel: viewModel, orientation: .landscapeLeft)
  }
}

#endif
