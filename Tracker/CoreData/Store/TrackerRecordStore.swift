
import Foundation
import CoreData

//MARK: - TrackerRecordStore
final class TrackerRecordStore {
    
    //MARK: - Private properties
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

//MARK: - TrackerRecordDataStore
extension TrackerRecordStore: TrackerRecordDataStore {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
    
    func add(trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        
        
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = Int64(trackerRecord.date)
        
        CoreDataManager.shared.saveContext()
    }
    
    func delete(trackerRecord: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        print("Date in Current Date - \(trackerRecord.date)")
        request.predicate = NSPredicate(format: "id == %@ AND date == %lld", trackerRecord.id as CVarArg, trackerRecord.date)
        if let trackerRecordCoreData = try context.fetch(request).first {
            context.delete(trackerRecordCoreData)
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func fetch() -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        do {
            let results = try context.fetch(request)
            print("Date in CoreData = \(results.first?.date)")
            return results.map { TrackerRecord(id: $0.id ?? UUID(), date: UInt64($0.date)) }
        } catch {
            print("Failed to fetch trackerRecords: \(error)")
            return []
        }
    }
}
