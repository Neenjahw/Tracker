
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
            return results.map { TrackerRecord(id: $0.id ?? UUID(), date: UInt64($0.date)) }
        } catch {
            print("Failed to fetch trackerRecords: \(error)")
            return []
        }
    }
    
    func calculateLongestStreak() -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        do {
            var trackerRecords = try context.fetch(request)
            trackerRecords.sort { $0.date < $1.date }
            
            var longestStreak = 0
            var currentStreak = 0
            var lastDate: Date?
            
            for record in trackerRecords {
                guard let date = Date(timeIntervalSince1970: TimeInterval(record.date)) as Date? else {
                    continue
                }
                
                if let last = lastDate {
                    let daysBetween = Calendar.current.dateComponents([.day], from: last, to: date).day ?? 0
                    if daysBetween == 1 {
                        currentStreak += 1
                    } else if daysBetween > 1 {
                        longestStreak = max(longestStreak, currentStreak)
                        currentStreak = 1
                    }
                } else {
                    currentStreak = 1
                }
                lastDate = date
            }
            
            longestStreak = max(longestStreak, currentStreak)
            
            return longestStreak
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return 0
        }
    }
    
    func calculatePerfectDays() -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        do {
            let trackerRecords = try context.fetch(request)
            
            guard !trackerRecords.isEmpty else { return 0 }
            
            let groupedByDate = Dictionary(grouping: trackerRecords, by: { record -> Date in
                let date = Date(timeIntervalSince1970: TimeInterval(record.date))
                return Calendar.current.startOfDay(for: date)
            })
            
            var perfectDaysCount = 0
            
            for (_ , records) in groupedByDate {
                let completedTrackerIDs = Set(records.compactMap { $0.id })
                let trackerRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
                let totalTrackers = try context.count(for: trackerRequest)
                if completedTrackerIDs.count == totalTrackers && totalTrackers > 0 {
                    perfectDaysCount += 1
                }
            }
            
            return perfectDaysCount
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return 0
        }
    }
    
    func calculateTotalHabitsCompleted() throws -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        do {
            let trackerRecords = try context.fetch(request)
            let totalCompletedHabits = trackerRecords.count
            
            return totalCompletedHabits
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return 0
        }
    }
    
    func calculateAverageHabitsPerDay() throws -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        do {
            let trackerRecords = try context.fetch(request)
            
            var habitsPerDay: [Date: Int] = [:]
            
            let calendar = Calendar.current
            
            for record in trackerRecords {
                let date = calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(record.date)))
                habitsPerDay[date, default: 0] += 1
            }
            guard !habitsPerDay.isEmpty else {
                return 0
            }
            
            let totalDays = habitsPerDay.count
            let totalHabits = habitsPerDay.values.reduce(0, +)
            let averageHabitsPerDay = totalHabits / totalDays
            
            return averageHabitsPerDay
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return 0
        }
    }
}
