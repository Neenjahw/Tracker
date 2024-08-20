
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
    
    func fetchCategories() -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        do {
            let trackerCategories = try context.fetch(request)
            
            var categories = trackerCategories.map { categoryCoreData in
                let title = categoryCoreData.title ?? ""
                let trackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerObjects = trackers.compactMap { trackerCoreData in
                    return Tracker(trackerCoreData: trackerCoreData)
                }
                return TrackerCategory(title: title, trackers: trackerObjects)
            }
            
            categories.sort { $0.title == "Закрепленные" ? true : $1.title == "Закрепленные" ? false : $0.title < $1.title }
            
            return categories
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
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
    
    func update(_ tracker: Tracker, for category: TrackerCategory) throws {
        let trackerRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        trackerRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        guard let trackersCoreData = try? context.fetch(trackerRequest),
              let trackerCoreData = trackersCoreData.first else { return }
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.isHabit = tracker.isHabit
        
        let categoryRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        categoryRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category.title)
        guard let trackerCategoriesCoreData = try? context.fetch(categoryRequest),
              let trackerCategoryCoreData = trackerCategoriesCoreData.first else { return }
        trackerCoreData.trackerCategory = trackerCategoryCoreData
        CoreDataManager.shared.saveContext()
    }
    
    func changePinnedState(for trackerId: UUID) throws {
        let trackerRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        guard let trackerCoreData = try? context.fetch(trackerRequest).first else { return }
        
        trackerCoreData.isPinned.toggle()
        
        if trackerCoreData.isPinned {
            trackerCoreData.originalCategory = trackerCoreData.trackerCategory
            try addTrackerToPinnedCategory(tracker: trackerCoreData)
        } else {
            try restoreTrackerToOriginalCategory(tracker: trackerCoreData)
        }
        
        CoreDataManager.shared.saveContext()
    }

    private func addTrackerToPinnedCategory(tracker: TrackerCoreData) throws {
        let pinnedCategory = try getOrCreatePinnedCategory()
        
        if let currentCategory = tracker.trackerCategory {
            currentCategory.removeFromTrackers(tracker)
        }
    
        pinnedCategory.addToTrackers(tracker)
    }
    
    private func restoreTrackerToOriginalCategory(tracker: TrackerCoreData) throws {
        guard let originalCategory = tracker.originalCategory else { return }
        
        if let pinnedCategory = try? getPinnedCategory() {
            pinnedCategory.removeFromTrackers(tracker)
        }
        
        originalCategory.addToTrackers(tracker)
        
        tracker.originalCategory = nil
    }

    private func removeTrackerFromPinnedCategory(tracker: TrackerCoreData) throws {
        if let pinnedCategory = try? getPinnedCategory() {
            pinnedCategory.removeFromTrackers(tracker)
            
        }
    }

    private func getOrCreatePinnedCategory() throws -> TrackerCategoryCoreData {
        if let pinnedCategory = try getPinnedCategory() {
            return pinnedCategory
        } else {
            
            let pinnedCategory = TrackerCategoryCoreData(context: context)
            pinnedCategory.title = "Закрепленные"
            return pinnedCategory
        }
    }

    private func getPinnedCategory() throws -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), "Закрепленные")
        
        return try context.fetch(request).first
    }
}
