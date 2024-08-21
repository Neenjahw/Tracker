
import CoreData

//MARK: - TrackerRecordDataStore
protocol TrackerRecordDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(trackerRecord: TrackerRecord) throws
    func delete(trackerRecord: TrackerRecord) throws
    func fetch() -> [TrackerRecord]
    func calculateLongestStreak() throws -> Int
    func calculatePerfectDays() throws -> Int
    func calculateTotalHabitsCompleted() throws -> Int
    func calculateAverageHabitsPerDay() throws -> Int
}
