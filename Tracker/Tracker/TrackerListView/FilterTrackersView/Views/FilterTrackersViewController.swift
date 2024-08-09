
import UIKit

//MARK: - FilterTrackersViewControllerDelegate
protocol FilterTrackersViewControllerDelegate: AnyObject {
    func edit(filterType: FilterType)
}

//MARK: - FilterTrackersViewController
final class FilterTrackersViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
    }
    
    //MARK: - Public Properties
    weak var delegate: FilterTrackersViewControllerDelegate?
    
    //MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date? = Date()
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(FilterTrackerCell.self, forCellReuseIdentifier: FilterTrackerCell.filterTrackerCellIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    
    //MARK: - Init
    init(categories: [TrackerCategory], completedTrackers: [TrackerRecord], delegate: FilterTrackersViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.categories = categories
        self.completedTrackers = completedTrackers
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
    }
}

//MARK: - UITableViewDelegate
extension FilterTrackersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FilterTrackerCell else { return }
        
        let filterType: [FilterType] = [
            .editAllTrackers,
            .editTrackersOnToday,
            .editCompletedTrackers,
            .editUncompletedTrackers
        ]
        
        if indexPath.row < filterType.count {
            delegate?.edit(filterType: filterType[indexPath.row])
        }
        
        cell.setCheckMark()
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FilterTrackerCell else { return }
        
        cell.removeCheckMark()
    }
}

//MARK: - UITableViewDataSource
extension FilterTrackersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTrackerCell.filterTrackerCellIdentifier, for: indexPath) as? FilterTrackerCell else { return UITableViewCell() }
        
        let filterTitles = [
            "Все трекеры",
            "Трекеры на сегодня",
            "Завершенные",
            "Не завершенные"
        ]
        
        if indexPath.row < filterTitles.count {
            cell.textLabel?.text = filterTitles[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

//MARK: - AutoLayout
extension FilterTrackersViewController {
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [titleLabel,
         tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
