import Foundation
import CoreData

//MARK: - TrackerStoreUpdate
struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

//MARK: - TrackerDataProviderProtocol
protocol TrackerCategoryDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCategory?
    func createCategory(_ category: TrackerCategory) throws
    func deleteCategory(with title: String) throws
    func fetchCategories() -> [TrackerCategory]
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws
}

protocol TrackerCategoryDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

//MARK: - TrackerDataProvider
final class TrackerCategoryDataProvider: NSObject {
    
    //MARK: - TrackerDataProviderErrors
    enum TrackerCategoryDataProviderErrors: Error {
        case failedToInitializeContext
        case failedToDeleteCategory
        case failedToCreateCategory
        case failedToUpdateCategory
    }
    
    //MARK: - Public Properties
    weak var delegate: TrackerCategoryDataProviderDelegate?
    
    //MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let trackerCategoryDataStore: TrackerCategoryDataStore
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        return fetchedResultController
    }()
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    
    //MARK: - Init
    init(trackerCategoryStore: TrackerCategoryDataStore, delegate: TrackerCategoryDataProviderDelegate) throws {
        guard let context = trackerCategoryStore.managedObjectContext else {
            throw TrackerCategoryDataProviderErrors.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.trackerCategoryDataStore = trackerCategoryStore
    }
}

//MARK: - TrackerDataProviderProtocol
extension TrackerCategoryDataProvider: TrackerCategoryDataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let trackerCategoryCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let title = trackerCategoryCoreData.title,
              let trackerCoreData = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData] else {
            return nil
        }
        
        let trackers = trackerCoreData.map({ Tracker(trackerCoreData: $0)})
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    func createCategory(_ category: TrackerCategory) throws {
        do {
            try trackerCategoryDataStore.create(category)
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToCreateCategory
        }
    }
    
    func fetchCategories() -> [TrackerCategory] {
        trackerCategoryDataStore.fetchCategories()
    }
    
    func deleteCategory(with title: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        do {
            let results = try context.fetch(request)
            for result in results as? [NSManagedObject] ?? [] {
                context.delete(result)
            }
            try context.save()
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToDeleteCategory
        }
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", category.title)
        do {
            let results = try context.fetch(request)
            if let existingCategory = results.first as? TrackerCategoryCoreData {
                existingCategory.title = newTitle
                try context.save()
            }
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToUpdateCategory
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryDataProvider: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard
            let insertedIndexes = insertedIndexes,
            let deletedIndexes = deletedIndexes,
            let updatedIndexes = updatedIndexes else { return }
        delegate?.didUpdate(
            .init(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes))
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            switch type {
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexes?.insert(indexPath.row)
                }
            case .insert:
                if let newIndexPath = newIndexPath {
                    insertedIndexes?.insert(newIndexPath.row)
                }
            case .update:
                if let indexPath = indexPath {
                    updatedIndexes?.insert(indexPath.row)
                }
            default:
                break
            }
        }
}
