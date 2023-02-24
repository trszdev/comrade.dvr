public protocol SessionStore: AnyObject {
  var session: Session? { get set }
}

public final class SessionStoreStub {
  public init() {}

  public var session: Session? {
    get { nil }
    set {}
  }
}

final class SessionStoreImpl: SessionStore, PreviewProvider {
  var session: Session?

  var backCameraPreviewView: PreviewView? { session?.backCameraPreviewView }
  var frontCameraPreviewView: PreviewView? { session?.frontCameraPreviewView }
}
