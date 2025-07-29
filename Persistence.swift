import CoreData

class PersistenceController: ObservableObject {
  let container = NSPersistentContainer(name: "Model")

  static let shared = PersistenceController()

  private init() {
    container.loadPersistentStores { description, error in
      if let error = error {
        print("Core Data failed to load: \(error.localizedDescription)")
      }
    }
  }
}
