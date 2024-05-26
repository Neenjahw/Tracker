
import Foundation

//MARK: - DataManager
final class DataManager {
    
    //MARK: - Static Properties
    static let shared = DataManager()
    
    //MARK: - Public Properties
    var categories: [TrackerCategory] = []
    
    //MARK: - Init
    private init() { }
    
    //MARK: - AddCategory
    func add(category: TrackerCategory) {
        categories.append(category)
    }
}
