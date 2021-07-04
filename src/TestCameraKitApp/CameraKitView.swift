import SwiftUI
import CameraKit

struct CameraKitView<ViewModel: CameraKitViewModel, Log: LogViewModel>: View {
  let consoleView: ConsoleView<Log>
  @ObservedObject var viewModel: ViewModel

  var body: some View {
    ZStack(alignment: .topTrailing) {
      Color.pink.ignoresSafeArea()
      HStack(alignment: .center, spacing: 0) {
        consoleView
        previews
      }
      HStack(alignment: .top) {
        pressureLevel.frame(width: 10, height: 10)
        VStack {
          CustomButton(text: "Request media chunk", action: viewModel.requestMediaChunk)
          CustomButton(text: "Stop", action: viewModel.stop)
        }
      }
    }
  }

  private var previews: some View {
    VStack {
      viewModel.previews.view
    }
  }

  private var pressureLevel: IdentifiableAnyView {
    switch viewModel.pressureLevel {
    case .nominal:
      return Color.green.eraseToAnyView()
    case .serious:
      return Color.yellow.eraseToAnyView()
    case .shutdown:
      return Color.red.eraseToAnyView()
    }
  }
}

extension Array where Element: View & Identifiable {
  var view: some View {
    ForEach(self) { $0 }
  }
}

private struct CustomButton: View {
  let text: String
  let action: () -> Void

  var body: some View {
    Button(text, action: action)
      .minimumScaleFactor(0.01)
      .frame(width: 50, height: 50)
      .padding(10)
      .background(Color.gray)
      .foregroundColor(.black)
  }
}

struct CameraKitViewPreview: PreviewProvider {
  static var previews: some View {
    let container = Assembly().hashContainer
    let consoleView = container.resolve(ConsoleView<LogViewModelImpl>.self)!
    let shareViewPresenter = container.resolve(ShareViewPresenter.self)!
    let logger = container.resolve(Logger.self)!
    logger.log("ahahah")
    logger.log("1234 123")
    logger.log("lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum")
    let viewModel = PreviewViewModel(logger: logger, shareViewPresenter: shareViewPresenter)
    return CameraKitView<PreviewViewModel, LogViewModelImpl>(consoleView: consoleView, viewModel: viewModel)
  }
}

private final class PreviewViewModel: CameraKitViewModel {
  let logger: Logger
  let shareViewPresenter: ShareViewPresenter

  init(logger: Logger, shareViewPresenter: ShareViewPresenter) {
    self.logger = logger
    self.shareViewPresenter = shareViewPresenter
    pressureLevelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      let newLevel = CKPressureLevel.allCases.randomElement()!
      self?.pressureLevel = newLevel
    }
  }

  private var pressureLevelTimer: Timer!

  func requestMediaChunk() {
    logger.log("request media chunk")
    shareViewPresenter.presentFile(url: URL(string: "https://example.com/media.m4a")!)
    shareViewPresenter.presentFile(url: URL(string: "https://example.com/media.mov")!)
  }

  func stop() {
  }

  @Published var pressureLevel: CKPressureLevel = .nominal
  var pressureLevelPublished: Published<CKPressureLevel> { _pressureLevel }
  var pressureLevelPublisher: Published<CKPressureLevel>.Publisher { $pressureLevel }

  lazy var previews: [IdentifiableAnyView] = {[
    Color.blue.eraseToAnyView(),
    Color.red.eraseToAnyView(),
  ]}()
}
