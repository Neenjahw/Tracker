
import CoreData

//MARK: - TrackerCategoryDataStore
protocol TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func create(_ category: TrackerCategory) throws
    func fetchCategories() -> [TrackerCategory]
    func add(_ tracker: Tracker, for category: TrackerCategory) throws
    func update(_ tracker: Tracker, for category: TrackerCategory) throws
    func changePinnedState(for trackerId: UUID) throws
}
