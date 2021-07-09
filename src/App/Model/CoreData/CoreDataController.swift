import Foundation
import CoreData

protocol CoreDataController {

}

class CoreDataControllerImpl: CoreDataController {
  var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores(completionHandler: { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  var context: NSManagedObjectContext {
    persistentContainer.viewContext
  }

  func saveContext () {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        context.rollback()
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}
