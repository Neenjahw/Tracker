
import CoreData

//MARK: - TrackerCategoryDataStore
protocol TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func create(_ category: TrackerCategory) throws
    func fetchAllCategories() -> [TrackerCategory]
    func addTrackerToCategory(_ tracker: Tracker, _ trackerCategory: TrackerCategory) throws
    func deleteCategory(_ trackerCategory: TrackerCategory) throws
    func deleteTracker(_ tracker: Tracker) throws
    func update(_ trackerCategory: TrackerCategory, with newTitle: String) throws
}
