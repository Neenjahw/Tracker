import Foundation
import CoreData

//MARK: - TrackerStoreUpdate
struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

//MARK: - TrackerDataProviderProtocol
protocol TrackerCategoryDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCategory?
    func tracker(at indexPath: IndexPath) -> Tracker?
    func createCategory(_ category: TrackerCategory) throws
    func deleteCategory(_ trackerCategory: TrackerCategory) throws
    func fetchAllCategories() -> [TrackerCategory]
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws
    func addTrackerToCategory(_ tracker: Tracker, _ trackerCategory: TrackerCategory) throws
    func deleteTracker(_ tracker: Tracker) throws
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
        case failedToAddTrackerToCategory
        case failedToDeleteTrackerFromCategory
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
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    
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
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        guard let sections = fetchedResultsController.sections,
              indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].numberOfObjects else {
            return nil
        }
        
        let trackerCategoryCoreData = fetchedResultsController.object(at: indexPath)
        guard let title = trackerCategoryCoreData.title,
              let trackerCoreData = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData] else {
            return nil
        }
        
        let trackers = trackerCoreData.map { Tracker(trackerCoreData: $0) }
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard let sections = fetchedResultsController.sections,
              indexPath.section < sections.count,
              let category = sections[indexPath.section].objects?.first as? TrackerCategoryCoreData,
              let trackersSet = category.trackers else {
            return nil
        }
        
        let trackersArray = Array(trackersSet) as? [TrackerCoreData] ?? []
        let sortedTrackers = trackersArray.sorted { ($0.name ?? "") < ($1.name ?? "") }
        
        guard indexPath.row < sortedTrackers.count else {
            return nil
        }
        
        let trackerCoreData = sortedTrackers[indexPath.row]
        return Tracker(trackerCoreData: trackerCoreData)
    }
    
    
    func createCategory(_ category: TrackerCategory) throws {
        do {
            try trackerCategoryDataStore.create(category)
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToCreateCategory
        }
    }
    
    func addTrackerToCategory(_ tracker: Tracker, _ trackerCategory: TrackerCategory) throws {
        do {
            try trackerCategoryDataStore.addTrackerToCategory(tracker, trackerCategory)
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToAddTrackerToCategory
        }
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        trackerCategoryDataStore.fetchAllCategories()
    }
    
    func deleteCategory(_ trackerCategory: TrackerCategory) throws {
        do {
            try trackerCategoryDataStore.deleteCategory(trackerCategory)
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToDeleteCategory
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        do {
            try trackerCategoryDataStore.deleteTracker(tracker)
        } catch {
            throw TrackerCategoryDataProviderErrors.failedToDeleteTrackerFromCategory
        }
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws {
        do {
            try trackerCategoryDataStore.update(category, with: newTitle)
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
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard
            let insertedIndexes = insertedIndexes,
            let deletedIndexes = deletedIndexes,
            let updatedIndexes = updatedIndexes,
            let insertedSections = insertedSections,
            let deletedSections = deletedSections else { return }
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
