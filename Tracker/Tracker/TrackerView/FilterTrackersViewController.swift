
import UIKit

//MARK: - FilterTrackersViewControllerDelegate
protocol FilterTrackersViewControllerDelegate: AnyObject {
    func filterCategories(_ filteredCategories: [TrackerCategory])
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
    
    //MARK: - Private Methods
    private func editAllTrackers() {
        self.filteredCategories = categories
        delegate?.filterCategories(filteredCategories)
    }
    
    private func editTrackersOnToday() {
        guard let currentDate = currentDate else { return }
        guard let todayDayOfWeek = convert(date: currentDate) else { return }
        
        filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.compactMap { tracker -> Tracker? in
                if tracker.schedule.contains(todayDayOfWeek) {
                    return Tracker(
                        id: tracker.id,
                        name: tracker.name,
                        color: tracker.color,
                        emoji: tracker.emoji,
                        schedule: [todayDayOfWeek],
                        isHabit: tracker.isHabit
                    )
                }
                return nil
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        delegate?.filterCategories(filteredCategories)
    }
    
    private func editCompletedTrackers() {
        filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.compactMap { tracker -> Tracker? in
                let matchingTrackers = completedTrackers.filter { completedTracker in
                    let date = Date(timeIntervalSince1970: TimeInterval(completedTracker.date))
                    guard let trackerRecordDate = convert(date: date) else { return false }
                    return tracker.id == completedTracker.id && tracker.schedule.contains(trackerRecordDate)
                }
                
                if !matchingTrackers.isEmpty {
                    let dates = matchingTrackers.compactMap { completedTracker -> DayOfWeek? in
                        let date = Date(timeIntervalSince1970: TimeInterval(completedTracker.date))
                        return convert(date: date)
                    }
                    return Tracker(
                        id: tracker.id,
                        name: tracker.name,
                        color: tracker.color,
                        emoji: tracker.emoji,
                        schedule: dates,
                        isHabit: tracker.isHabit
                    )
                }
                return nil
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        delegate?.filterCategories(filteredCategories)
    }
    
    private func editUncompletedTrackers() {
        filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.compactMap { tracker -> Tracker? in
                let uncompletedDates = tracker.schedule.filter { scheduleDate in
                    let matchingTrackers = completedTrackers.contains { completedTracker in
                        let date = Date(timeIntervalSince1970: TimeInterval(completedTracker.date))
                        guard let trackerRecordDate = convert(date: date) else { return false }
                        return tracker.id == completedTracker.id && trackerRecordDate == scheduleDate && date <= currentDate ?? Date()
                    }
                    return !matchingTrackers
                }
                
                if !uncompletedDates.isEmpty {
                    return Tracker(
                        id: tracker.id,
                        name: tracker.name,
                        color: tracker.color,
                        emoji: tracker.emoji,
                        schedule: uncompletedDates,
                        isHabit: tracker.isHabit
                    )
                }
                return nil
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        delegate?.filterCategories(filteredCategories)
    }
    
    private func isCurrentDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    private func convert(date: Date) -> DayOfWeek? {
        let date = Calendar.current.component(.weekday, from: date) - 1
        return DayOfWeek(rawValue: date)
    }
}

//MARK: - UITableViewDelegate
extension FilterTrackersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FilterTrackerCell else { return }
        
        switch indexPath.row {
        case 0:
            editAllTrackers()
        case 1:
            editTrackersOnToday()
        case 2:
            editCompletedTrackers()
        case 3:
            editUncompletedTrackers()
        default:
            cell.textLabel?.text = ""
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
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Все трекеры"
        case 1:
            cell.textLabel?.text = "Трекеры на сегодня"
        case 2:
            cell.textLabel?.text = "Завершенные"
        case 3:
            cell.textLabel?.text = "Не завершенные"
        default:
            cell.textLabel?.text = ""
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
