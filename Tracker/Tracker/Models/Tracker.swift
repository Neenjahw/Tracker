
import UIKit

//MARK: - Tracker
struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DayOfWeek]
    let type: TrackerType
}
