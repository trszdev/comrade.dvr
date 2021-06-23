import SwiftUI
import Combine
import CameraKit

struct ConfigureCameraBitrateCellViewBuilder {
  let modalViewPresenter: ModalViewPresenter

  func makeView(
    selected: Binding<CKBitrate>,
    resolution: CKSize,
    title: @escaping (AppLocale) -> String,
    sfSymbol: SFSymbol,
    separator: [Edge] = [Edge.bottom],
    isDisabled: Bool = false
  ) -> ConfigureCameraBitrateCellView {
    ConfigureCameraBitrateCellView(
      selected: selected,
      resolution: resolution,
      modalViewPresenter: modalViewPresenter,
      title: title,
      sfSymbol: sfSymbol,
      separator: separator,
      isDisabled: isDisabled
    )
  }
}

struct ConfigureCameraBitrateCellView: View {
  init(
    selected: Binding<CKBitrate>,
    resolution: CKSize,
    modalViewPresenter: ModalViewPresenter,
    title: @escaping (AppLocale) -> String,
    sfSymbol: SFSymbol,
    separator: [Edge] = [Edge.bottom],
    isDisabled: Bool = false
  ) {
    self._selected = selected
    self.resolution = resolution
    self._modalSelected = StateObject(wrappedValue: ObservableValue(Double(selected.wrappedValue.bitsPerSecond)))
    self.modalViewPresenter = modalViewPresenter
    self.title = title
    self.sfSymbol = sfSymbol
    self.separator = separator
    self.isDisabled = isDisabled
  }

  @Environment(\.theme) var theme: Theme
  @Environment(\.appLocale) var appLocale: AppLocale
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  @Binding var selected: CKBitrate
  let resolution: CKSize
  let modalViewPresenter: ModalViewPresenter
  let title: (AppLocale) -> String
  let sfSymbol: SFSymbol
  var separator = [Edge.bottom]
  var isDisabled = false

  var body: some View {
    TableCellView(
      centerView: Text(title(appLocale)).eraseToAnyView(),
      rightView: Text(appLocale.bitrate(selected)).eraseToAnyView(),
      sfSymbol: sfSymbol,
      separator: separator,
      isDisabled: isDisabled
    )
    .onTapGesture {
      modalViewPresenter.presentView(content: modalContentView)
    }
    .onAppear {
      modalViewPresenter.submitPublisher
        .sink(receiveValue: onSubmit)
        .store(in: &cancellables.value)
      modalSelected.objectWillChange
        .sink(receiveValue: modalViewPresenter.updateModal)
        .store(in: &cancellables.value)
    }
  }

  func modalContentView() -> AnyView {
    let closestKey = resolutionSuggestions.keys.min { abs(resolution.scalar - $0) < abs(resolution.scalar - $1) }
    let suggestions = resolutionSuggestions[closestKey ?? 0] ?? [:]
    let maxValue = (suggestions.values.max() ?? 1) * 1.5
    let minValue = (suggestions.values.min() ?? 1) * 0.5
    return VStack {
      VStack(spacing: 0) {
        Text(title(appLocale))
        Text(appLocale.bitrate(selectedBitrate)).padding(.top, 18)
        Slider(value: $modalSelected.value, in: minValue...maxValue).padding(.vertical, 10)
      }
      .padding(.top, 18)
      .padding(.horizontal, 10)
      VStack(spacing: 0) {
        ForEach(suggestions.sorted(by: >), id: \.key) { text, bitrate in
          buttonView(text: Text(text)) {
            self.modalSelected.value = bitrate
          }
        }
      }
    }
    .eraseToAnyView()
  }

  private func buttonView(text: Text, action: @escaping () -> Void) -> some View {
    let isDark = colorScheme == .dark
    return VStack(spacing: 0) {
      Divider().background(isDark ? Color.white : Color.clear)
      Button(action: action, label: { text.frame(maxWidth: .infinity).padding(12) })
      .buttonStyle(ModalViewButtonStyle(isDark: isDark))
    }
    .frame(maxWidth: .infinity)
  }

  private func onSubmit() {
    selected = selectedBitrate
  }

  private var selectedBitrate: CKBitrate {
    CKBitrate(bitsPerSecond: Int(modalSelected.value))
  }

  private var cancellables = Ref<Set<AnyCancellable>>([])
  @StateObject private var modalSelected: ObservableValue<Double>
}

// https://support.google.com/youtube/answer/1722171
private let resolutionSuggestions: [Int: [String: Double]] = [
  CKSize(width: 3840, height: 2160).scalar: [
    "2160p 30FPS SDR": 35_000_000,
    "2160p 60FPS SDR": 53_000_000,
    "2160p 30FPS HDR": 44_000_000,
    "2160p 60FPS HDR": 66_000_000,
  ],
  CKSize(width: 2560, height: 1440).scalar: [
    "1440p 30FPS SDR": 16_000_000,
    "1440p 60FPS SDR": 24_000_000,
    "1440p 30FPS HDR": 20_000_000,
    "1440p 60FPS HDR": 30_000_000,
  ],
  CKSize(width: 1920, height: 1080).scalar: [
    "1080p 30FPS SDR": 8_000_000,
    "1080p 60FPS SDR": 12_000_000,
    "1080p 30FPS HDR": 10_000_000,
    "1080p 60FPS HDR": 15_000_000,
  ],
  CKSize(width: 1280, height: 720).scalar: [
    "720p 30FPS SDR": 5_000_000,
    "720p 60FPS SDR": 7_500_000,
    "720p 30FPS HDR": 6_500_000,
    "720p 60FPS HDR": 9_500_000,
  ],
  CKSize(width: 640, height: 480).scalar: [
    "480p 30FPS SDR": 2_500_000,
    "480p 60FPS SDR": 4_000_000,
  ],
]

struct ConfigureCameraBitrateCellViewPreviews: PreviewProvider {
  static var previews: some View {
    let view = locator.resolve(ConfigureCameraBitrateCellViewBuilder .self).makeView(
      selected: .constant(CKBitrate(bitsPerSecond: 30_000)),
      resolution: CKSize(width: 1920, height: 1080),
      title: { $0.fullAppName },
      sfSymbol: .language
    )
    VStack {
      view
      view.environment(\.theme, DarkTheme())
      ModalView(isVisible: true, content: view.modalContentView)
      ModalView(isVisible: true, content: view.modalContentView).colorScheme(.dark)
    }
    .padding()
    .background(Color.gray)
  }
}
