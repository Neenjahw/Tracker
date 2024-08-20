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
    func editTracker(at id: UUID) throws -> Tracker
    func deleteTracker(at id: UUID) throws
    func add(_ tracker: Tracker, for category: TrackerCategory) throws 
    func editCategory(with trackerId: UUID) throws -> TrackerCategory
    func update(_ tracker: Tracker, for category: TrackerCategory) throws
    func changePinnedState(for trackerId: UUID) throws
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
        case failedToEditCategory
        case failedToEditTracker
        case failedToDeleteTracker
        case failedToUpdateTracker
        case failedToAddTrackerToCategory
        case failedToChangePinnedState
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
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        do {
            let categories = try context.fetch(request)
            for category in categories {
                context.delete(category)
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
    
    func editTracker(at id: UUID) throws -> Tracker {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(request).first {
                return Tracker(trackerCoreData: tracker)
            } else {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
            }
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToEditTracker
        }
    }
    
    func editCategory(with trackerId: UUID) throws -> TrackerCategory {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        request.predicate = NSPredicate(format: "SUBQUERY(trackers, $tracker, $tracker.id == %@).@count > 0", trackerId as CVarArg)
        
        do {
            if let category = try context.fetch(request).first {
                return TrackerCategory(trackerCategoryCoreData: category)
            } else {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
            }
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToEditCategory
        }
    }

    
    func deleteTracker(at id: UUID) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let trackers = try context.fetch(request)
            for tracker in trackers {
                context.delete(tracker)
            }
            try context.save()
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToDeleteTracker
        }
    }
    
    func add(_ tracker: Tracker, for category: TrackerCategory) throws {
        do {
            try trackerCategoryDataStore.add(tracker, for: category)
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToAddTrackerToCategory
        }
    }
    
    func update(_ tracker: Tracker, for category: TrackerCategory) throws {
        do {
            try trackerCategoryDataStore.update(tracker, for: category)
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToUpdateTracker
        }
    }
    
    func changePinnedState(for trackerId: UUID) throws {
        do {
            try trackerCategoryDataStore.changePinnedState(for: trackerId)
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToChangePinnedState
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
