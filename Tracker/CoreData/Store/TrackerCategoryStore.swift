
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
        CoreDataManager.shared.saveContext()
    }
    
    func addTrackerToCategory(_ tracker: Tracker, _ trackerCategory: TrackerCategory) {
        let trackerCoreData = TrackerCoreData(context: context)
        
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), trackerCategory.title)
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
    
    func deleteCategory(_ trackerCategory: TrackerCategory) {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        guard let categories = try? context.fetch(request),
              let category = categories.first(where: { $0.title == trackerCategory.title }) else { return }
        context.delete(category)
        CoreDataManager.shared.saveContext()
    }
    
    func deleteTracker(_ tracker: Tracker) {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        guard let trackers = try? context.fetch(request),
              let tracker = trackers.first(where: { $0.id == tracker.id }) else { return }
        context.delete(tracker)
        
        CoreDataManager.shared.saveContext()
    }
    
    func update(_ trackerCategory: TrackerCategory, with newTitle: String) {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        guard let categories = try? context.fetch(request),
              let category = categories.first(where: { $0.title == trackerCategory.title }) else { return }
        category.title = newTitle
        CoreDataManager.shared.saveContext()
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        do {
            let trackerCategories = try context.fetch(request)
            
            return trackerCategories.map { categoryCoreData in
                let title = categoryCoreData.title ?? ""
                let trackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerObjects = trackers.compactMap { trackerCoreData in
                    return Tracker(trackerCoreData: trackerCoreData)
                }
                let sortedTrackers = trackerObjects.sorted { ($0.name) < ($1.name) }
                return TrackerCategory(title: title, trackers: trackerObjects)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
}
