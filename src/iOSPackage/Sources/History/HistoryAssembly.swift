import SwinjectExtensions
import Swinject
import SwinjectAutoregistration
import ThumbnailKit
import ComposableArchitecture

public enum HistoryAssembly: SharedAssembly {
  case shared

  public func assembleWithChildren(container: Container) -> [SharedAssembly] {
    container.registerSingleton(ObservableImageCache.self, name: .thumbnailCache) { resolver in
      resolver.resolve(ObservableImageCache.self, argument: 20)!
    }
    container.register(HistoryView.self) { resolver in
      .init(
        store: resolver.resolve(Store<HistoryState, HistoryAction>.self)!,
        observableImageCache: resolver.resolve(ObservableImageCache.self, name: .thumbnailCache)!
      )
    }
    container
      .autoregister(HistoryRepository.self, initializer: HistoryRepositoryImpl.init)
      .inObjectScope(.container)
    return [ThumbnailAssembly.shared]
  }
}

private extension String {
  static var thumbnailCache: Self { "thumbnail" }
}
