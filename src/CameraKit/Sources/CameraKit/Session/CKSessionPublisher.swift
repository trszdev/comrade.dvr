import Combine

struct CKSessionPublisher {
  let outputPublisher = PassthroughSubject<CKMediaChunk, Error>()
  let pressureLevelPublisher = PassthroughSubject<CKPressureLevel, Never>()
}

protocol CKSessionPublisherProvider {
  var sessionPublisher: CKSessionPublisher { get }
}

extension CKSessionPublisherProvider {
  var outputPublisher: AnyPublisher<CKMediaChunk, Error> {
    sessionPublisher.outputPublisher.eraseToAnyPublisher()
  }

  var pressureLevelPublisher: AnyPublisher<CKPressureLevel, Never> {
    sessionPublisher.pressureLevelPublisher.eraseToAnyPublisher()
  }
}
