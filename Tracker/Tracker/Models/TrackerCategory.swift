
import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
    
    init(trackerCategoryCoreData: TrackerCategoryCoreData) {
        self.title = trackerCategoryCoreData.title ?? "Unknown Category"
        
        if let coreDataTrackers = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData] {
            self.trackers = coreDataTrackers.map { Tracker(trackerCoreData: $0) }
        } else {
            self.trackers = []
        }
    }
}

