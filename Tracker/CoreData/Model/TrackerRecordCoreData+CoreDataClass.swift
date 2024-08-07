
import Foundation
import CoreData

@objc(TrackerRecordCoreData)
public class TrackerRecordCoreData: NSManagedObject {
    
    @NSManaged public var date: Int64
    @NSManaged public var id: UUID?
    @NSManaged public var tracker: TrackerRecordCoreData?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
}
