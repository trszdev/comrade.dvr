import AutocontainerKit

struct StartViewAssembly: AKAssembly {
  func assemble(container: AKContainer) {
    container.transient.autoregister(construct: StartViewModelBuilder.init(
      devicesModel:
      configureMicrophoneViewBuilder:
      configureCameraViewBuilder:
      appLocaleModel:
      navigationViewPresenter:
      app:
      sessionModel:
    ))
  }
}
