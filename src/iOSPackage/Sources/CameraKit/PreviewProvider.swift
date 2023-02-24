public protocol PreviewProvider {
  var frontCameraPreviewView: PreviewView? { get }
  var backCameraPreviewView: PreviewView? { get }
}

public enum PreviewProviderStub: PreviewProvider {
  case shared

  public var frontCameraPreviewView: PreviewView? { nil }
  public var backCameraPreviewView: PreviewView? { nil }
}
