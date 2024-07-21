
import Foundation
import CoreData


extension TrackerRecordCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    @NSManaged public var date: Int64
    @NSManaged public var id: UUID?
    @NSManaged public var tracker: TrackerRecordCoreData?

}

extension TrackerRecordCoreData : Identifiable {

}
