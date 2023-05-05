import ComposableArchitecture

public extension AnyReducer where Environment == Void {
  func pullback<GlobalState, GlobalAction, GlobalEnvironment>(
    state toLocalState: WritableKeyPath<GlobalState, State>,
    action toLocalAction: CasePath<GlobalAction, Action>
  ) -> AnyReducer<GlobalState, GlobalAction, GlobalEnvironment> {
    pullback(state: toLocalState, action: toLocalAction) { _ in () }
  }

  func store(initialState: State) -> Store<State, Action> {
    .init(initialState: initialState, reducer: self)
  }
}

public extension AnyReducer {
  func store(initialState: State, environment: Environment) -> Store<State, Action> {
    .init(initialState: initialState, reducer: self, environment: environment)
  }
}
