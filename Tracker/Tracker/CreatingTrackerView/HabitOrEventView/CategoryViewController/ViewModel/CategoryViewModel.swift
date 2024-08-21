
import Foundation

typealias CategoryBinding<T> = (T) -> Void
//MARK: - CategoryViewModel
final class CategoryViewModel {
    
    // MARK: - Public Properties
    var categoryCreated: CategoryBinding<[IndexPath]>?
    var categoryDeleted: CategoryBinding<[IndexPath]>?
    var categoryUpdated: CategoryBinding<[IndexPath]>?
    var onErrorStateChange: CategoryBinding<String>?
    
    //MARK: - Private Properties
    private var insertedIndexPaths: [IndexPath]?
    private var deletedIndexPaths: [IndexPath]?
    private var updatedIndexesPaths: [IndexPath]?
    
    private lazy var trackerCategoryDataProvider: TrackerCategoryDataProviderProtocol? = {
        let trackerCategoryDataStore = TrackerCategoryStore()
        do {
            try trackerCategoryDataProvider = TrackerCategoryDataProvider(trackerCategoryStore:trackerCategoryDataStore,
                                                                          delegate: self)
            return trackerCategoryDataProvider
        } catch {
            onErrorStateChange?("Не удалось инициализировать TrackerCategoryDataProvider")
            return nil
        }
    }()
    
    private var categories: [TrackerCategory] {
        let allCategories = trackerCategoryDataProvider?.fetchCategories() ?? []
        return allCategories.filter { $0.title != "Закрепленные" }
    }
    
    // MARK: - Public Methods
    func fetchCategories() -> [TrackerCategory]? {
        let allCategories = trackerCategoryDataProvider?.fetchCategories() ?? []
        
        let filteredCategories = allCategories.filter { $0.title != "Закрепленные" }
        
        return filteredCategories
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return categories.count
    }
    
    func editCategory(at indexPath: IndexPath) -> TrackerCategory? {
        guard indexPath.row < categories.count else { return nil }
        return categories[indexPath.row]
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        guard let category = editCategory(at: indexPath) else { return }
        do {
            try trackerCategoryDataProvider?.deleteCategory(with: category.title)
            categoryDeleted?(deletedIndexPaths ?? [])
        } catch {
            onErrorStateChange?("Не удалось удалить категорию")
        }
    }
    
    func createCategory(_ category: TrackerCategory) {
        do {
            try trackerCategoryDataProvider?.createCategory(category)
            categoryCreated?(insertedIndexPaths ?? [])
        } catch {
            onErrorStateChange?("Не удалось создать категорию")
        }
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) {
        do {
            try trackerCategoryDataProvider?.updateCategory(category, with: newTitle)
            categoryUpdated?(updatedIndexesPaths ?? [])
        } catch {
            onErrorStateChange?("Не удалось обновить категорию")
        }
    }
}

//MARK: - TrackerCategoryDataProviderDelegate
extension CategoryViewModel: TrackerCategoryDataProviderDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        insertedIndexPaths = update.insertedIndexes.map { IndexPath(row: $0, section: 0) }
        deletedIndexPaths = update.deletedIndexes.map { IndexPath(row: $0, section: 0) }
        updatedIndexesPaths = update.updatedIndexes.map { IndexPath(row: $0, section: 0) }
    }
}
