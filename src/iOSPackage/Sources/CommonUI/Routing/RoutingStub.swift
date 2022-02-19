public final class RoutingStub: Routing {
  public nonisolated init() {}

  public var tabRouting: TabRouting?
  public var loadingRouting: LoadingRouting?
  public var sessionRouting: SessionRouting?

  public func selectTab(animated: Bool) async {
  }

  public func selectLoading(animated: Bool) async {
  }

  public func selectSession(animated: Bool) async {
  }
}
