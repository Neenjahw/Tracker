
import CoreData

//MARK: - TrackerRecordDataStore
protocol TrackerRecordDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(trackerRecord: TrackerRecord) throws
    func delete(trackerRecord: TrackerRecord) throws
    func fetch() -> [TrackerRecord]
}
