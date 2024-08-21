
import UIKit

//MARK: - TrackerViewController
final class TrackerListViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let navLeftTitleLabelFontSize: CGFloat = 34
        static let placeholderLabelFontSize: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 34
        static let dateLabelFontSize: CGFloat = 17
        static let dateLabelCornerRadius: CGFloat = 8
    }
    
    //MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date?
    private var dateChangeInDatePicker: Bool?
    private var filterType: FilterType?
    private var analyticsService = AnalyticsService()
    
    private lazy var trackerCategoryDataProvider: TrackerCategoryDataProviderProtocol? = {
        let trackerCategoryDataStore = TrackerCategoryStore()
        do {
            try trackerCategoryDataProvider = TrackerCategoryDataProvider(trackerCategoryStore:trackerCategoryDataStore,
                                                                          delegate: self)
            return trackerCategoryDataProvider
        } catch {
            print("Данные не доступны")
            return nil
        }
    }()
    
    private lazy var trackerRecordDataProvider: TrackerRecordDataProviderProtocol? = {
        let trackerRecordDataStore = TrackerRecordStore()
        do {
            try trackerRecordDataProvider = TrackerRecordDataProvider(trackerRecordStore:trackerRecordDataStore,
                                                                      delegate: self)
            return trackerRecordDataProvider
        } catch {
            print("Данные не доступны")
            return nil
        }
    }()
    
    //MARK: - UIModels
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton()
        button.setImage(.addTracker.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        button.tintColor = .label
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .boldSystemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .ypDateBackground
        label.font = .systemFont(ofSize: UIConstants.dateLabelFontSize)
        label.textAlignment = .center
        label.textColor = .black
        label.layer.cornerRadius = UIConstants.dateLabelCornerRadius
        label.layer.zPosition = 10
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 14
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .ypBlue
        button.isHidden = true
        button.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.backgroundColor = .ypLightGray
        textField.textColor = .ypBlack
        textField.delegate = self
        textField.clearButtonMode = .never
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypGray2
        ]
        let searchText = NSLocalizedString("search", comment: "Text displayed on search")
        let attributedPlaceholder = NSAttributedString(
            string: searchText,
            attributes: attributes)
        textField.attributedPlaceholder = attributedPlaceholder
        return textField
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholderTrackerView
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.placeholderLabelFontSize)
        label.text = "Что будем отслеживать?"
        label.isHidden = true
        return label
    }()
    
    private lazy var placeholderSearchTrackerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholderTrackerSearch
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var placeholderSearchTrackerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.placeholderLabelFontSize)
        label.text = "Ничего не найдено"
        label.isHidden = true
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(chooseFilterForTrackers), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerListCell.self, forCellWithReuseIdentifier: TrackerListCell.collectionCellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
        collectionView.backgroundColor = .ypBackground
        return collectionView
    }()
    
    //MARK: - Init - deinit
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        analyticsService.report(event: "close", screen: "TrackerListViewController")
    }
    
    //MARK: - Lifycylce
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        currentDate = Date()
        updateDateLabelTitle(with: Date())
        reloadData()
        analyticsService.report(event: "open", screen: "TrackerListViewController")
        localize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - Private Methods
    private func reloadData() {
        if let trackerCategories = trackerCategoryDataProvider?.fetchCategories() {
            categories = trackerCategories
            completedTrackers = trackerRecordDataProvider?.fetch() ?? []
            filterType = .editAllTrackers
            reloadVisibleCategories()
            setPlaceholderImage()
        }
    }
    
    private func setPlaceholderImage() {
        let noCategories = categories.isEmpty
        let noVisibleCategories = visibleCategories.isEmpty
        
        placeholderImageView.isHidden = !noCategories
        placeholderLabel.isHidden = !noCategories
        placeholderSearchTrackerImage.isHidden = !(!noCategories && noVisibleCategories)
        placeholderSearchTrackerLabel.isHidden = !(!noCategories && noVisibleCategories)
    }
    
    private func reloadVisibleCategories() {
        let filterType = loadFilterType()
        
        if filterType == .editTrackersOnToday {
            if dateChangeInDatePicker ?? false {
                editTrackersOnToday()
                updateDateLabelTitle(with: currentDate ?? Date())
            } else {
                currentDate = Date()
                datePicker.date = currentDate!
                editTrackersOnToday()
                updateDateLabelTitle(with: datePicker.date)
            }
            dateChangeInDatePicker = false
        } else {
            switch filterType {
            case .editAllTrackers:
                editAllTrackers()
                dateChangeInDatePicker = false
            case .editCompletedTrackers:
                editCompletedTrackers()
                dateChangeInDatePicker = false
            case .editUncompletedTrackers:
                editUncompletedTrackers()
                dateChangeInDatePicker = false
            default:
                print("")
            }
        }
    }
    
    func loadFilterType() -> FilterType {
        guard let rawValue = UserDefaults.standard.string(forKey: "filterType") else { return .editAllTrackers }
        return FilterType(rawValue: rawValue) ?? .editAllTrackers
    }
    
    private func editAllTrackers() {
        let calendar = Calendar.current
        guard let selectedDate = currentDate else { return }
        let filterText = (searchTextField.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                var dateCondition = false
                
                if tracker.isHabit == true {
                    let filterWeekDay = calendar.component(.weekday, from: selectedDate)
                    dateCondition = tracker.schedule.contains { dayOfWeek in
                        let dayOfWeekIndex = dayOfWeek.rawValue
                        let filterWeekDayAdjusted = filterWeekDay == 1 ? 7 : filterWeekDay - 1
                        return dayOfWeekIndex == filterWeekDayAdjusted
                    }
                } else {
                    let today = Date()
                    dateCondition = calendar.isDate(today, inSameDayAs: selectedDate)
                }
                return textCondition && dateCondition
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        setPlaceholderImage()
    }
    
    private func editTrackersOnToday() {
        let calendar = Calendar.current
        guard let selectedDate = currentDate else { return }
        let filterText = (searchTextField.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                var dateCondition = false
                
                if tracker.isHabit == true {
                    let filterWeekDay = calendar.component(.weekday, from: selectedDate)
                    dateCondition = tracker.schedule.contains { dayOfWeek in
                        let dayOfWeekIndex = dayOfWeek.rawValue
                        let filterWeekDayAdjusted = filterWeekDay == 1 ? 7 : filterWeekDay - 1
                        return dayOfWeekIndex == filterWeekDayAdjusted
                    }
                } else {
                    let today = Date()
                    dateCondition = calendar.isDate(today, inSameDayAs: selectedDate)
                }
                return textCondition && dateCondition
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        setPlaceholderImage()
    }
    
    private func editCompletedTrackers() {
        let calendar = Calendar.current
        guard let selectedDate = currentDate else { return }
        let filterText = (searchTextField.text ?? "").lowercased()
        guard let trackerRecords = trackerRecordDataProvider?.fetch() else { return }
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchingRecords = trackerRecords.filter { record in
                    tracker.id == record.id
                }
                
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                let dateCondition = matchingRecords.contains { record in
                    let recordDate = self.convert(date: record.date)
                    return calendar.isDate(recordDate, inSameDayAs: selectedDate)
                }
                
                return textCondition && dateCondition
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        setPlaceholderImage()
    }
    
    private func editUncompletedTrackers() {
        let calendar = Calendar.current
        guard let selectedDate = currentDate else { return }
        let filterText = (searchTextField.text ?? "").lowercased()
        guard let trackerRecords = trackerRecordDataProvider?.fetch() else { return }
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let filterWeekDay = calendar.component(.weekday, from: selectedDate) - 1
                let isScheduledForSelectedDate = tracker.schedule.contains(DayOfWeek(rawValue: filterWeekDay) ?? .monday)
                
                let matchingRecords = trackerRecords.filter { record in
                    tracker.id == record.id
                }
                
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                let dateCondition = !matchingRecords.contains { record in
                    let recordDate = self.convert(date: record.date)
                    return calendar.isDate(recordDate, inSameDayAs: selectedDate)
                }
                
                return isScheduledForSelectedDate && textCondition && dateCondition
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        setPlaceholderImage()
    }
    
    private func convert(date: UInt64) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(date))
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }
    
    private func isCurrentDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    private func updateDateLabelTitle(with date: Date) {
        let dateString = formattedDate(from: date)
        dateLabel.text = dateString
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let trackerRecordDate = Date(timeIntervalSince1970: TimeInterval(trackerRecord.date))
        guard let currentDate = currentDate else { return true}
        let isSameDay = Calendar.current.isDate(trackerRecordDate, inSameDayAs: currentDate)
        return trackerRecord.id == id && isSameDay
    }
    
    private func pinOrUnpinTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        try? trackerCategoryDataProvider?.changePinnedState(for: tracker.id)
        reloadData()
    }
    
    @objc private func datePickerValueChanged() {
        dateChangeInDatePicker = true
        currentDate = datePicker.date
        guard let currentDate = currentDate else { return }
        updateDateLabelTitle(with: currentDate)
        reloadVisibleCategories()
    }
    
    @objc private func createTracker() {
        analyticsService.report(event: "click", screen: "TrackerListViewController", item: "create_track")
        let creatingTrackerViewController = CreatingTrackerViewController()
        let navigationController = UINavigationController(rootViewController: creatingTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func clearTextField() {
        searchTextField.text = ""
        cancelButton.isHidden = true
        reloadVisibleCategories()
    }
    
    @objc private func chooseFilterForTrackers() {
        let filterTrackersViewController = FilterTrackersViewController(categories: categories, completedTrackers: completedTrackers, delegate: self)
        analyticsService.report(event: "click", screen: "TrackerListViewController", item: "filter")
        present(filterTrackersViewController, animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension TrackerListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategories()
        cancelButton.isHidden = false
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        editAllTrackers()
        cancelButton.isHidden = updatedText.isEmpty
        setPlaceholderImage()
        
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        if offsetY >= 10 {
            filterButton.isHidden = true
        } else {
            filterButton.isHidden = false
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackerListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 2 - 20
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: collectionView.frame.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerListCell else { return nil }
            
            let originalBackgroundColor = cell.trackerCardView.backgroundColor
            cell.trackerCardView.backgroundColor = originalBackgroundColor?.withAlphaComponent(0.8)
            
            let params = UIPreviewParameters()
            params.backgroundColor = .clear
            
            let targetedPreview = UITargetedPreview(view: cell.trackerCardView, parameters: params)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                cell.trackerCardView.backgroundColor = originalBackgroundColor
            }
            
            return targetedPreview
        }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint) -> UIContextMenuConfiguration? {
            guard indexPaths.count > 0 else { return nil }
            
            let indexPath = indexPaths[0]
            
            let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
            let editingTracker = try? trackerCategoryDataProvider?.editTracker(at: tracker.id)
            let completedDays = completedTrackers.filter {
                $0.id == tracker.id
            }.count
            let category = (try? trackerCategoryDataProvider?.editCategory(with: tracker.id)) ?? TrackerCategory(title: "", trackers: [])
            
            let editTrackerText = NSLocalizedString("editTracker", comment: "Text displayed on edit Tracker")
            let pinTrackerText = NSLocalizedString("pinTracker", comment: "Text displayed on edit Tracker")
            let unpinTrackerText = NSLocalizedString("unpinTracker", comment: "Text displayed on edit Tracker")
            let deleteText = NSLocalizedString("delete", comment: "Text displayed on delete Tracker")
            let cancelText = NSLocalizedString("cancel", comment: "Text displayed on cancel delete Tracker")
            let deleteConfirmation = NSLocalizedString("delete.confirmation", comment: "Text displayed on delete Tracker title")
            return UIContextMenuConfiguration(actionProvider: { actions in
                return UIMenu(
                    children: [
                        UIAction(title: tracker.isPinned ? unpinTrackerText : pinTrackerText, handler: { _ in
                            self.pinOrUnpinTracker(at: indexPath)
                        }),
                        UIAction(title: editTrackerText) { _ in
                            let habitOrEventViewController = HabitOrEventViewController(tracker: editingTracker, in: category, completedDays: completedDays, isEditingTracker: true)
                            self.analyticsService.report(event: "click", screen: "TrackerListViewController", item: "edit_tracker")
                            self.present(habitOrEventViewController, animated: true)
                        },
                        UIAction(title: deleteText, attributes: .destructive) { _ in
                            self.analyticsService.report(event: "click", screen: "TrackerListViewController", item: "delete_tracker")
                            let alertController = UIAlertController(
                                title: "",
                                message: deleteConfirmation,
                                preferredStyle: .actionSheet)
                            
                            let deleteAction = UIAlertAction(
                                title: deleteText,
                                style: .destructive) { _ in
                                    try? self.trackerCategoryDataProvider?.deleteTracker(at: tracker.id)
                                    self.reloadData()
                                }
                            
                            let cancelAction = UIAlertAction(
                                title: cancelText,
                                style: .cancel)
                            
                            alertController.addAction(deleteAction)
                            alertController.addAction(cancelAction)
                            
                            self.present(alertController, animated: true)
                        }
                    ])
            })
        }
}

//MARK: - UICollectionViewDataSource
extension TrackerListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        setPlaceholderImage()
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerListCell.collectionCellIdentifier, for: indexPath) as? TrackerListCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count
        cell.configure(
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            isPinned: tracker.isPinned,
            at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView
        view?.titleLabel.text = visibleCategories[indexPath.section].title
        return view!
    }
}

//MARK: - TrackerCellDelegate
extension TrackerListViewController: TrackerListCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        guard let currentDate = currentDate else { return }
        if !isCurrentDate(currentDate) && currentDate > Date() { return }
        
        let trackerDate = startOfDay(for: currentDate)
        let trackerRecord = TrackerRecord(id: id, date: trackerDate)
        
        do {
            try trackerRecordDataProvider?.add(trackerRecord: trackerRecord)
            completedTrackers.append(trackerRecord)
            analyticsService.report(event: "click", screen: "TrackerListViewController", item: "complete_tracker")
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerListCell {
                cell.setCompletedState(true)
            }
            collectionView.reloadData()
        } catch {
            print("Failed to add tracker record: \(error)")
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        guard let currentDate = currentDate else { return }
        if !isCurrentDate(currentDate) && currentDate > Date() { return }
        
        let trackerDate = startOfDay(for: currentDate)
        let trackerRecord = TrackerRecord(id: id, date: trackerDate)
        
        do {
            try trackerRecordDataProvider?.delete(trackerRecord: trackerRecord)
            if let index = completedTrackers.firstIndex(where: { $0.id == id && $0.date == trackerRecord.date }) {
                completedTrackers.remove(at: index)
                if let cell = collectionView.cellForItem(at: indexPath) as? TrackerListCell {
                    cell.setCompletedState(false)
                }
            }
            collectionView.reloadData()
        } catch {
            print("Failed to delete tracker record: \(error)")
        }
    }
    
    private func startOfDay(for date: Date) -> UInt64 {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return UInt64(startOfDay.timeIntervalSince1970)
    }
}

//MARK: - TrackerDataProviderDelegate
extension TrackerListViewController: TrackerCategoryDataProviderDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        collectionView.performBatchUpdates {
            let insertedIndexPath = update.insertedIndexes.map { IndexPath(item: $0, section: $0) }
            let deletedIndexPath = update.deletedIndexes.map { IndexPath(item: $0, section: $0) }
            collectionView.insertItems(at: insertedIndexPath)
            collectionView.deleteItems(at: deletedIndexPath)
        }
    }
}

//MARK: - TrackerDataProviderDelegate
extension TrackerListViewController: TrackerRecordDataProviderDelegate {
    func didUpdate(_ update: TrackerRecordStoreUpdate) {
        collectionView.performBatchUpdates {
            let insertedIndexPath = update.insertedIndexes.map { IndexPath(item: $0, section: $0) }
            let deletedIndexPath = update.deletedIndexes.map { IndexPath(item: $0, section: $0) }
            collectionView.insertItems(at: insertedIndexPath)
            collectionView.deleteItems(at: deletedIndexPath)
        }
    }
}

//MARK: - FilterTrackersViewControllerDelegate
extension TrackerListViewController: FilterTrackersViewControllerDelegate {
    func edit(filterType: FilterType) {
        UserDefaults.standard.set(filterType.rawValue, forKey: "filterType")
        reloadVisibleCategories()
    }
}

//MARK: - AutoLayout
extension TrackerListViewController {
    private func setupViews() {
        view.backgroundColor = .ypBackground
        [addTrackerButton,
         titleLabel,
         datePicker,
         searchStackView,
         collectionView,
         placeholderImageView,
         placeholderLabel,
         placeholderSearchTrackerImage,
         placeholderSearchTrackerLabel,
         filterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [searchTextField,
         cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            searchStackView.addArrangedSubview($0)
        }
        
        datePicker.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: datePicker.centerXAnchor),
            dateLabel.heightAnchor.constraint(equalTo: datePicker.heightAnchor),
            dateLabel.widthAnchor.constraint(equalTo: datePicker.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            placeholderImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -246),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            
            placeholderSearchTrackerImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -246),
            placeholderSearchTrackerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeholderSearchTrackerLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderSearchTrackerLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

//MARK: - Localize
extension TrackerListViewController {
    func localize() {
        let emptyStateText = NSLocalizedString("emptyState.title", comment: "Text displayed on empty state")
        let filterText = NSLocalizedString("filters", comment: "Text displayed on filter button")
        let titleText = NSLocalizedString("trackers", comment: "Text displayed on title")
        let cancelText = NSLocalizedString("cancel", comment: "Text displayed on cancel search button")
        placeholderLabel.text = emptyStateText
        filterButton.setTitle(filterText, for: .normal)
        titleLabel.text = titleText
        cancelButton.setTitle(cancelText, for: .normal)
    }
}

