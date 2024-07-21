
import Foundation
import CoreData


extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var isHabit: Bool
    @NSManaged public var color: NSObject?
    @NSManaged public var schedule: NSObject?
    @NSManaged public var trackerCategory: TrackerCategoryCoreData?

}

extension TrackerCoreData : Identifiable {

}
