
import Foundation
import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {
    
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var isHabit: Bool
    @NSManaged public var color: NSObject?
    @NSManaged public var schedule: NSObject?
    @NSManaged public var trackerCategory: TrackerCategoryCoreData?
    @NSManaged public var isPinned: Bool
    @NSManaged public var originalCategory: TrackerCategoryCoreData?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
}
