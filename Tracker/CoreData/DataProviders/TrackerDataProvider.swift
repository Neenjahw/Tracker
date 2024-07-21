
import Foundation
import CoreData

//MARK: - TrackerStoreUpdate
struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

//MARK: - TrackerDataProviderProtocol
protocol TrackerDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, for category: TrackerCategory) throws
    func clearData()
}

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

//MARK: - TrackerDataProvider
final class TrackerDataProvider: NSObject {
    
    //MARK: - TrackerDataProviderErrors
    enum TrackerDataProviderErrors: Error {
        case failedToInitializeContext
    }
    
    //MARK: - Public Properties
    weak var delegate: TrackerDataProviderDelegate?
    
    //MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let trackerDataStore: TrackerDataStore
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
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
    init(trackerStore: TrackerDataStore, delegate: TrackerDataProviderDelegate) throws {
        guard let context = trackerStore.managedObjectContext else {
            print("Ошибка инициализации контекста")
            throw TrackerDataProviderErrors.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.trackerDataStore = trackerStore
    }
}
//MARK: - TrackerDataProviderProtocol
extension TrackerDataProvider: TrackerDataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return Tracker(trackerCoreData: trackerCoreData)
    }
    
    func addTracker(_ tracker: Tracker, for category: TrackerCategory) throws {
        try? trackerDataStore.add(tracker, for: category)
    }
    
    func clearData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCoreData")
        do {
            let results = try context.fetch(request)
            for result in results as! [NSManagedObject] {
                context.delete(result)
            }
            
            try context.save()
        } catch {
            print("Не удалось удалить данные")
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insertedIndexes!,
            deletedIndexes: deletedIndexes!
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = indexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
