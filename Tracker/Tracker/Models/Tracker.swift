
import UIKit

//MARK: - Tracker
struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DayOfWeek]
    let isHabit: Bool
    
    init(trackerCoreData: TrackerCoreData) {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let color = trackerCoreData.color as? UIColor,
              let emoji = trackerCoreData.emoji,
              let schedule = trackerCoreData.schedule as? [DayOfWeek]
        else {
            fatalError("Some property is nil in Tracker")
        }
        
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isHabit = trackerCoreData.isHabit
    }
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [DayOfWeek], isHabit: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isHabit = isHabit
    }
}
