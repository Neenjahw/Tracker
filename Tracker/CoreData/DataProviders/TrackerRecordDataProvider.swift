
import Foundation
import CoreData

//MARK: - TrackerStoreUpdate
struct TrackerRecordStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

//MARK: - TrackerDataProviderProtocol
protocol TrackerRecordDataProviderProtocol {
    func add(trackerRecord: TrackerRecord) throws
    func delete(trackerRecord: TrackerRecord) throws
    func fetch() -> [TrackerRecord]
}

protocol TrackerRecordDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerRecordStoreUpdate)
}

//MARK: - TrackerDataProvider
final class TrackerRecordDataProvider: NSObject {
    
    //MARK: - TrackerDataProviderErrors
    enum TrackerRecordDataProviderErrors: Error {
        case failedToInitializeContext
    }
    
    //MARK: - Public Properties
    weak var delegate: TrackerRecordDataProviderDelegate?
    
    //MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let trackerRecordDataStore: TrackerRecordDataStore
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
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
    init(trackerRecordStore: TrackerRecordDataStore, delegate: TrackerRecordDataProviderDelegate) throws {
        guard let context = trackerRecordStore.managedObjectContext else {
            print("Ошибка инициализации контекста")
            throw TrackerRecordDataProviderErrors.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.trackerRecordDataStore = trackerRecordStore
    }
}

//MARK: - TrackerDataProviderProtocol
extension TrackerRecordDataProvider: TrackerRecordDataProviderProtocol {
    func add(trackerRecord: TrackerRecord) throws {
        do {
            try? trackerRecordDataStore.add(trackerRecord: trackerRecord)
        } catch {
            print("Ошибка создания категории: \(error)")
            throw error
        }
    }
    
    func delete(trackerRecord: TrackerRecord) throws {
        do {
            try? trackerRecordDataStore.delete(trackerRecord: trackerRecord)
        } catch {
            print("Ошибка создания категории: \(error)")
            throw error
        }
    }
    
    func fetch() -> [TrackerRecord] {
        trackerRecordDataStore.fetch()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordDataProvider: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes = insertedIndexes, let deletedIndexes = deletedIndexes else {
            return
        }
        delegate?.didUpdate(TrackerRecordStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes
        ))
        self.insertedIndexes = nil
        self.deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
