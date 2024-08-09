import Foundation

@objc
final class DayOfWeekValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let daysOfWeek = value as? [DayOfWeek] else { return nil }
        do {
            let data = try JSONEncoder().encode(daysOfWeek)
            return data
        } catch {
            print("Ошибка при кодировании: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let daysOfWeek = try JSONDecoder().decode([DayOfWeek].self, from: data)
            return daysOfWeek
        } catch {
            print("Ошибка при декодировании: \(error)")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DayOfWeekValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DayOfWeekValueTransformer.self))
        )
    }
}
