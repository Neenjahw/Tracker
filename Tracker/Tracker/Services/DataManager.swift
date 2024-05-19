
import Foundation

//MARK: - DataManager
final class DataManager {
    
    //MARK: - Static Properties
    static let shared = DataManager()
    
    //MARK: - Public Properties
    var categories: [TrackerCategory] = [
        TrackerCategory(
            title: "Фитнес",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Бег",
                    color: .ypRed,
                    emoji: "🏃‍♂️",
                    schedule: [DayOfWeek.monday, DayOfWeek.wednesday]),
                Tracker(
                    id: UUID(),
                    name: "Присядания",
                    color: .ypBlue,
                    emoji: "🦿",
                    schedule: [DayOfWeek.tuesday, DayOfWeek.thursday])]),
        TrackerCategory(
            title: "Путешествия",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Поездка в милан",
                    color: .ypGray,
                    emoji: "🎒",
                    schedule: [DayOfWeek.saturday])])
    ]
    
    //MARK: - Init
    private init() { }
}
