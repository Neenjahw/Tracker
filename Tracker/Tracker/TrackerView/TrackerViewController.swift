
import UIKit

//MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let navLeftTitleLabelFontSize: CGFloat = 34
        static let placeholderLabelFontSize: CGFloat = 12
    }
    
    //MARK: - Public Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerRecord] = []
    private var completedTrackers: [TrackerRecord] = []
    
    //MARK: - UIModels
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yy"
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholderTrackerView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.placeholderLabelFontSize)
        label.text = "Что будем отслеживать?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: CollectionCell.collectionCellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
        // Mock data
        let tracker1 = Tracker(id: UUID(), name: "Бег", color: .ypRed, emoji: "🏃‍♂️", schedule: [:])
        let tracker2 = Tracker(id: UUID(), name: "Присядания", color: .greenHex, emoji: "👄", schedule: [:])
        let tracker3 = Tracker(id: UUID(), name: "Поездка в Милан", color: .ypBlue, emoji: "🤘", schedule: [:])
        
        let category1 = TrackerCategory(title: "Фитнес", trackers: [tracker1, tracker2])
        let category2 = TrackerCategory(title: "Путешествия", trackers: [tracker3])
        categories = [category1, category2]
        collectionView.reloadData()
    }
    
    //MARK: - Private Methods
    private func setPlaceholderImage() {
        if categories.count == 0 {
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
        }
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    @objc private func createTracker() {
        let creatingTrackerViewController = CreatingTrackerViewController()
        present(creatingTrackerViewController, animated: true)
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
        print("Number of sections: \(categories.count)")
        setPlaceholderImage()
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = categories[section].trackers.count
        print("Number of items in section \(section): \(numberOfItems)")
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Configuring cell at indexPath: \(indexPath)")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCell.collectionCellIdentifier, for: indexPath) as? CollectionCell else {
            return UICollectionViewCell()
        }
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        cell.setTrackerCardLabel(for: tracker.name)
        cell.setTrackerCardView(for: tracker.color)
        cell.setTintColorTrackerDoneButton(for: tracker.color)
        cell.setTrackerCardEmojiLabel(for: tracker.emoji)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("Configuring supplementary view at indexPath: \(indexPath)")
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView
        view?.titleLabel.text = categories[indexPath.section].title
        return view!
    }
}

//MARK: - HabitViewControllerDelegate
extension TrackerViewController: HabitViewControllerDelegate {
    func makeTrackerCategory(with title: String, nameOfTracker: String, schedule: [DayOfWeek : Bool]) {
        let newTracker = Tracker(id: UUID(), name: nameOfTracker, color: .greenHex, emoji: "💄", schedule: schedule)
        let newCategory = TrackerCategory(title: title, trackers: [newTracker])
        
        categories.append(newCategory)
    }
}

//MARK: - AutoLayout
extension TrackerViewController {
    private func initialize() {
        setupForNavBar()
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }
    
    private func setupForNavBar() {
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .addTracker, style: .plain, target: self, action: #selector(createTracker))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let searchController = UISearchController()
        navigationItem.searchController = searchController
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
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

