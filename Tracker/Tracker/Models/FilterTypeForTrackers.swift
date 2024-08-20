
import Foundation

enum FilterType: String {
    
    case editAllTrackers = "filter.allTrackers"
    case editTrackersOnToday = "filter.trackersOnToday"
    case editCompletedTrackers = "filter.completed"
    case editUncompletedTrackers = "filter.uncompleted"
    
    static var allValues: [FilterType] {
        return [.editAllTrackers, .editTrackersOnToday, .editCompletedTrackers, .editUncompletedTrackers]
    }
    
    var localizedString: String {
        return NSLocalizedString(self.rawValue, comment: "Text displayed on filter type")
    }
}
