import ComposableArchitecture

public struct PaywallState: Equatable {
  public init() {}
}

public enum PaywallAction {
  case tapSubscribe
  case tapRestore
  case tapRules
}

public let paywallReducer = Reducer<PaywallState, PaywallAction, Void> { _, _, _ in
  .none
}
