import ComposableArchitecture

public extension Store {
  convenience init(initialState: State, reducer: AnyReducer<State, Action, Void>) {
    self.init(
      initialState: initialState,
      reducer: reducer,
      environment: ()
    )
  }
}
