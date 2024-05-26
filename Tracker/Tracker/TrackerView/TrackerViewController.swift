
import UIKit

//MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let navLeftTitleLabelFontSize: CGFloat = 34
        static let placeholderLabelFontSize: CGFloat = 12
        static let titleLabelFontSize: CGFloat = 34
        static let dateLabelFontSize: CGFloat = 17
        static let dateLabelCornerRadius: CGFloat = 8
    }
    
    //MARK: - Private Properties
    private var visibleCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date?
    
    private let dataManager = DataManager.shared
    
    //MARK: - UIModels
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton()
        button.setImage(.addTracker, for: .normal)
        button.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
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
        button.setTitle("Отменить", for: .normal)
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
            NSAttributedString.Key.foregroundColor: UIColor.ypGray
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: attributes)
        textField.attributedPlaceholder = attributedPlaceholder
        return textField
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholderTrackerView
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.placeholderLabelFontSize)
        label.text = "Что будем отслеживать?"
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.collectionCellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    //MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifycylce
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        currentDate = Date()
        updateDateLabelTitle(with: Date())
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - Private Methods
    private func reloadData() {
        categories = dataManager.categories
        visibleCategories = categories
        reloadVisibleCategories()
    }
    
    private func setPlaceholderImage() {
        placeholderImageView.isHidden = !visibleCategories.isEmpty
        placeholderLabel.isHidden = !visibleCategories.isEmpty
    }
    
    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        guard let currentDate = currentDate else { return }
        let currentDay = calendar.component(.day, from: currentDate)
        let filterText = (searchTextField.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                var dateCondition = false
                switch tracker.type {
                case .habit:
                    dateCondition = tracker.schedule.contains { dayOfWeek in
                        let filterWeekDay = calendar.component(.weekday, from: currentDate)
                        let weekDay = dayOfWeek.rawValue
                        return filterWeekDay == (weekDay == 1 ? 7 : weekDay - 1)
                    }
                case .irregularEvent:
                    if isCurrentDate(currentDate) {
                        let creationDate = Date()
                        dateCondition = calendar.isDate(creationDate, inSameDayAs: currentDate)
                    }
                }
                
                return textCondition && dateCondition
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        collectionView.reloadData()
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
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        guard let currentDate = currentDate else { return }
        updateDateLabelTitle(with: currentDate)
        reloadVisibleCategories()
    }
    
    @objc private func createTracker() {
        let creatingTrackerViewController = CreatingTrackerViewController()
        present(creatingTrackerViewController, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc private func clearTextField() {
        searchTextField.text = ""
        cancelButton.isHidden = true
    }
}

//MARK: - UITextFieldDelegate
extension TrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategories()
        cancelButton.isHidden = false
        return true
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
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
}

//MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        setPlaceholderImage()
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = visibleCategories[section].trackers.count
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.collectionCellIdentifier, for: indexPath) as? TrackerCell else {
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
extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        guard let currentDate = currentDate else { return }
        if !isCurrentDate(currentDate) && currentDate > Date() { return }
        let trackerDate = UInt(currentDate.timeIntervalSince1970)
        let trackerRecord = TrackerRecord(id: id, date: trackerDate)
        completedTrackers.append(trackerRecord)
        if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell {
            cell.setCompletedState(true)
        }
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        guard let currentDate = currentDate else { return }
        if !isCurrentDate(currentDate) && currentDate > Date() { return }
        
        if let index = completedTrackers.firstIndex(where: { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }) {
            completedTrackers.remove(at: index)
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell {
                cell.setCompletedState(false)
            }
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

//MARK: - AutoLayout
extension TrackerViewController {
    private func initialize() {
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [addTrackerButton,
         titleLabel,
         datePicker,
         searchStackView,
         collectionView,
         placeholderImageView,
         placeholderLabel].forEach {
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
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor)
        ])
    }
}

