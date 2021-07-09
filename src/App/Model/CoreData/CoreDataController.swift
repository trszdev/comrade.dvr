import Foundation
import CoreData
import Combine

protocol CoreDataController {
  var viewContext: AnyPublisher<NSManagedObjectContext, Error> { get }
  var backgroundContext: AnyPublisher<NSManagedObjectContext, Error> { get }
}

class CoreDataControllerImpl: CoreDataController {
  var viewContext: AnyPublisher<NSManagedObjectContext, Error> {
    containerPublisher.map(\.viewContext).eraseToAnyPublisher()
  }

  var backgroundContext: AnyPublisher<NSManagedObjectContext, Error> {
    containerPublisher
      .map { $0.newBackgroundContext() }
      .subscribe(on: DispatchQueue.global(qos: .background))
      .eraseToAnyPublisher()
  }

  private var containerFuture: Future<NSPersistentContainer, Error>?
  private let containerQueue = DispatchQueue()

  private var containerPublisher: AnyPublisher<NSPersistentContainer, Error> {
    containerQueue.sync {
      if let future = containerFuture {
        return future.eraseToAnyPublisher()
      }
      let future = Future<NSPersistentContainer, Error> { promise in
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (_, error) in
          guard let error = error else {
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergePolicy.overwrite
            return promise(.success(container))
          }
          print(error.localizedDescription)
          promise(.failure(error))
        }
      }
      containerFuture = future
      return future.eraseToAnyPublisher()
    }
  }
}
