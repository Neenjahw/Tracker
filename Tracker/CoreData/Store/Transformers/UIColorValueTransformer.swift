
import UIKit

@objc
final class UIColorValueTransformer: ValueTransformer {
    
    override final class func transformedValueClass() -> AnyClass { NSData.self }
    override final class func allowsReverseTransformation() -> Bool { true }
    
    struct ColorComponents: Codable {
        let red: CGFloat
        let blue: CGFloat
        let green: CGFloat
        let alpha: CGFloat
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil}
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let components = ColorComponents(red: red, blue: blue, green: green, alpha: alpha)
        return try? JSONEncoder().encode(components)
        
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        guard let components = try? JSONDecoder().decode(ColorComponents.self, from: data as Data) else { return nil}
        return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: components.alpha)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            UIColorValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: UIColorValueTransformer.self))
        )
    }
}
