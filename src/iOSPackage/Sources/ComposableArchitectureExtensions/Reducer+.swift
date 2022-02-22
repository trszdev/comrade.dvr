import ComposableArchitecture

public extension Reducer where Environment == Void {
  func pullback<GlobalState, GlobalAction, GlobalEnvironment>(
    state toLocalState: WritableKeyPath<GlobalState, State>,
    action toLocalAction: CasePath<GlobalAction, Action>
  ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
    pullback(state: toLocalState, action: toLocalAction) { _ in () }
  }

  func store(initialState: State) -> Store<State, Action> {
    .init(initialState: initialState, reducer: self)
  }
}

public extension Reducer {
  func store(initialState: State, environment: Environment) -> Store<State, Action> {
    .init(initialState: initialState, reducer: self, environment: environment)
  }
}
