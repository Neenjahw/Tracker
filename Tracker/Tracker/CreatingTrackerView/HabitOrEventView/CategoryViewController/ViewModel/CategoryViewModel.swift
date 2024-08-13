
import Foundation

typealias CategoryBinding<T> = (T) -> Void
//MARK: - CategoryViewModel
final class CategoryViewModel {
    
    // MARK: - Public Properties
    var categoryCreated: CategoryBinding<[IndexPath]>?
    var categoryDeleted: CategoryBinding<[IndexPath]>?
    var categoryUpdated: CategoryBinding<[IndexPath]>?
    var onErrorStateChange: CategoryBinding<String>?
    var categoryCreatedSections: CategoryBinding<IndexSet>?
    var categoryDeletedSections: CategoryBinding<IndexSet>?
    
    //MARK: - Private Properties
    private var insertedIndexPaths: [IndexPath]?
    private var deletedIndexPaths: [IndexPath]?
    private var updatedIndexesPaths: [IndexPath]?
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    
    //    private lazy var trackerCategoryDataProvider: TrackerCategoryDataProviderProtocol? = {
    //        let trackerCategoryDataStore = TrackerCategoryStore()
    //        do {
    //            try trackerCategoryDataProvider = TrackerCategoryDataProvider(trackerCategoryStore:trackerCategoryDataStore,
    //                                                                          delegate: self)
    //            return trackerCategoryDataProvider
    //        } catch {
    //            onErrorStateChange?("Не удалось инициализировать TrackerCategoryDataProvider")
    //            return nil
    //        }
    //    }()
    
    private lazy var trackerDataProvider: TrackerDataProviderProtocol? = {
        let trackerDataStore = TrackerStore()
        do {
            try trackerDataProvider = TrackerDataProvider(trackerStore:trackerDataStore,
                                                          delegate: self)
            return trackerDataProvider
        } catch {
            print("Данные не доступны")
            return nil
        }
    }()
    
    // MARK: - Public Methods
    //    func fetchCategories() -> [TrackerCategory]? {
    //        trackerCategoryDataProvider?.fetchAllCategories().filter({ $0.trackers.isEmpty })
    //    }
    //
    //    func numberOfRowsInSection(_ section: Int) -> Int {
    //        trackerCategoryDataProvider?.numberOfRowsInSection(section) ?? 0
    //    }
    //
    //    func editCategory(at indexPath: IndexPath) -> TrackerCategory? {
    //        trackerCategoryDataProvider?.object(at: indexPath)
    //    }
    //
    //    func deleteCategory(_ trackerCategory: TrackerCategory) {
    //        do {
    //            try trackerCategoryDataProvider?.deleteCategory(trackerCategory)
    //            categoryDeleted?(deletedIndexPaths ?? [])
    //        } catch {
    //            onErrorStateChange?("Не удалось удалить категорию")
    //        }
    //    }
    //
    //    func createCategory(_ category: TrackerCategory) {
    //        do {
    //            try trackerCategoryDataProvider?.createCategory(category)
    //            categoryCreated?(insertedIndexPaths ?? [])
    //        } catch {
    //            onErrorStateChange?("Не удалось создать категорию")
    //        }
    //    }
    //
    //    func updateCategory(_ category: TrackerCategory, with newTitle: String) {
    //        do {
    //            try trackerCategoryDataProvider?.updateCategory(category, with: newTitle)
    //            categoryUpdated?(updatedIndexesPaths ?? [])
    //        } catch {
    //            onErrorStateChange?("Не удалось обновить категорию")
    //        }
    //    }
    
    func numberOfSections() -> Int {
        return trackerDataProvider?.numberOfSections ?? 0
    }
    func numberOfRowsInSection(_ section: Int) -> Int {
        return trackerDataProvider?.numberOfRowsInSection(section) ?? 0
    }
    
    func fetchCategories() -> [TrackerCategory] {
        trackerDataProvider?.fetchCategories() ?? [TrackerCategory(title: "", trackers: [])]
    }
    
    func create(_ category: TrackerCategory) {
        do {
            try trackerDataProvider?.create(category)
            categoryCreatedSections?(insertedSections ?? [])
        } catch {
            onErrorStateChange?("Не удалось создать категорию")
        }
    }
    
    func editCategory(at indexPath: IndexPath) -> TrackerCategory? {
        trackerDataProvider?.editCategory(at: indexPath)
    }
}

//MARK: - TrackerCategoryDataProviderDelegate
//extension CategoryViewModel: TrackerCategoryDataProviderDelegate {
//    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
//        insertedIndexPaths = update.insertedIndexes.map { IndexPath(row: $0, section: 0) }
//        deletedIndexPaths = update.deletedIndexes.map { IndexPath(row: $0, section: 0) }
//        updatedIndexesPaths = update.updatedIndexes.map { IndexPath(row: $0, section: 0) }
//    }
//}

extension CategoryViewModel: TrackerDataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        insertedIndexPaths = update.insertedIndexes.map { IndexPath(row: $0, section: 0) }
        deletedIndexPaths = update.deletedIndexes.map { IndexPath(row: $0, section: 0) }
        updatedIndexesPaths = update.updatedIndexes.map { IndexPath(row: $0, section: 0) }
        insertedSections = update.insertedSections
        deletedSections = update.deletedSections
    }
}
