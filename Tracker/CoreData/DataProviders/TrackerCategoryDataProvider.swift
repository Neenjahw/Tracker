import Foundation
import CoreData

//MARK: - TrackerStoreUpdate
struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

//MARK: - TrackerDataProviderProtocol
protocol TrackerCategoryDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCategory?
    func createCategory(_ category: TrackerCategory) throws
    func clearData() throws
    func fetchCategories() -> [TrackerCategory]
}

protocol TrackerCategoryDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

//MARK: - TrackerDataProvider
final class TrackerCategoryDataProvider: NSObject {
    
    //MARK: - TrackerDataProviderErrors
    enum TrackerCategoryDataProviderErrors: Error {
        case failedToInitializeContext
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
            try? trackerCategoryDataStore.create(category)
        } catch {
            throw error
        }
    }
    
    func fetchCategories() -> [TrackerCategory] {
        trackerCategoryDataStore.fetchCategories()
    }
    
    func clearData() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        
        do {
            let results = try context.fetch(request)
            for result in results as? [NSManagedObject] ?? [] {
                context.delete(result)
            }
            try context.save()
        } catch {
            throw error
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryDataProvider: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes = insertedIndexes, let deletedIndexes = deletedIndexes else {
            return
        }
        delegate?.didUpdate(
            .init(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes))
        self.insertedIndexes = nil
        self.deletedIndexes = nil
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
        default:
            break
        }
    }
}
