
import CoreData

//MARK: - TrackerStoreUpdate
struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

//MARK: - TrackerDataProviderProtocol
protocol TrackerDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, for category: TrackerCategory) throws
    func deleteTracker(_ tracker: Tracker) throws
    func headerForSection(at indexPath: IndexPath) -> String
    func fetchCategories() -> [TrackerCategory]
    func create(_ category: TrackerCategory) throws
    func editCategory(at indexPath: IndexPath) -> TrackerCategory?
}

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

//MARK: - TrackerDataProvider
final class TrackerDataProvider: NSObject {
    
    //MARK: - TrackerDataProviderErrors
    enum TrackerDataProviderErrors: Error {
        case failedToInitializeContext
        case failedToDeleteTrackerFromCategory
    }
    
    //MARK: - Public Properties
    weak var delegate: TrackerDataProviderDelegate?
    
    //MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let trackerDataStore: TrackerDataStore
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trackerCategory.title", ascending: false)]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "trackerCategory.title",
            cacheName: nil)
        
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        return fetchedResultController
    }()
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    
    //MARK: - Init
    init(trackerStore: TrackerDataStore, delegate: TrackerDataProviderDelegate) throws {
        guard let context = trackerStore.managedObjectContext else {
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
        print("NumberOfSections in FRC = \(String(describing: fetchedResultsController.sections?.count ?? 0))")
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        print("NumberOfRowsInSection FRC \(section) = \(String(describing: fetchedResultsController.sections?[section].name))")
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func editCategory(at indexPath: IndexPath) -> TrackerCategory? {
        let category = fetchedResultsController.sections?[indexPath.section].objects as? TrackerCategory
        print("Edit category \(String(describing: category))")
        return category
    }
    
    func headerForSection(at indexPath: IndexPath) -> String {
        return fetchedResultsController.sections?[indexPath.section].name ?? ""
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return Tracker(trackerCoreData: trackerCoreData)
    }
    
    func addTracker(_ tracker: Tracker, for category: TrackerCategory) throws {
        try? trackerDataStore.add(tracker, for: category)
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        do {
            try trackerDataStore.deleteTracker(tracker)
        } catch {
            throw TrackerDataProviderErrors.failedToDeleteTrackerFromCategory
        }
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        do {
            let trackerCategories = try context.fetch(request)
            print("Fetched categories count: \(trackerCategories.count)")
            return trackerCategories.map { categoryCoreData in
                let title = categoryCoreData.title ?? ""
                let trackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerObjects = trackers.compactMap { trackerCoreData in
                    return Tracker(trackerCoreData: trackerCoreData)
                }
                let sortedTrackers = trackerObjects.sorted { ($0.name) < ($1.name) }
                print("TrackerCategory fetch \(trackerCategories)")
                return TrackerCategory(title: title, trackers: sortedTrackers)
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func create(_ category: TrackerCategory) {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = NSSet()
        CoreDataManager.shared.saveContext()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes = insertedIndexes,
              let deletedIndexes = deletedIndexes,
              let updatedIndexes = updatedIndexes,
              let insertedSections = insertedSections,
              let deletedSections = deletedSections else {
            return
        }
        delegate?.didUpdate(
            .init(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes,
                insertedSections: insertedSections,
                deletedSections: deletedSections))
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
        self.insertedSections = nil
        self.deletedSections = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            switch type {
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexes?.insert(indexPath.item)
                }
            case .insert:
                if let indexPath = indexPath {
                    insertedIndexes?.insert(indexPath.item)
                }
            case.update:
                if let indexPath = indexPath {
                    updatedIndexes?.insert(indexPath.item)
                }
            default:
                break
            }
        }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange sectionInfo: any NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
            switch type {
            case .insert:
                insertedSections?.insert(sectionIndex)
            case .delete:
                deletedSections?.insert(sectionIndex)
            default:
                break
            }
        }
}
