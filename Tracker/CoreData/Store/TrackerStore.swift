
import CoreData

//MARK: - TrackerStore
final class TrackerStore {
    
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

//MARK: - TrackerDataStore
extension TrackerStore: TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
    
    func add(_ tracker: Tracker, for category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category.title)
        guard let trackerCategoryCoreData = try? context.fetch(request).first else { return }
        
        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.isHabit = tracker.isHabit
        trackerCoreData.trackerCategory = trackerCategoryCoreData
        trackerCategoryCoreData.addToTrackers(trackerCoreData)
        
        CoreDataManager.shared.saveContext()
    }
}

