import ComposableArchitecture

public extension Store {
  convenience init(initialState: State, reducer: Reducer<State, Action, Void>) {
    self.init(
      initialState: initialState,
      reducer: reducer,
      environment: ()
    )
  }
}
