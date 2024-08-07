
import CoreData

//MARK: - TrackerStore
final class TrackerCategoryStore {
    
    //MARK: - Private Properties
    private var context: NSManagedObjectContext
    
    //MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
}

//MARK: - TrackerCategoryDataStore
extension TrackerCategoryStore: TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
    
    func create(_ category: TrackerCategory) {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = []
        CoreDataManager.shared.saveContext()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        do {
            let trackerCategories = try context.fetch(request)
            
            return trackerCategories.map { categoryCoreData in
                let title = categoryCoreData.title ?? ""
                let trackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerObjects = trackers.compactMap { trackerCoreData in
                    return Tracker(trackerCoreData: trackerCoreData)
                }
                return TrackerCategory(title: title, trackers: trackerObjects)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
}
