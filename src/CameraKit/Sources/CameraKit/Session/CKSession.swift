public protocol CKSession {
  var configuration: CKConfiguration { get }
  var isRunning: Bool { get set }
  var plugins: [CKSessionPlugin] { get set }
}
