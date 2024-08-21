
import UIKit

//MARK: - StatisticsViewController
final class StatisticsViewController: UIViewController {
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 34
    }
    
    private var longestStreak: Int?
    private var perfectDays: Int?
    private var habitsCompleted: Int?
    private var averageHabitsPerDay: Int?
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: UIConstants.titleLabelFontSize)
        label.textColor = .label
        return label
    }()
    
    private lazy var placeholderImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = .statisticsPlaceHolder
        return imageView
    }()    
    
    private lazy var placeholderLabel: UILabel = {
       let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.statisticsCellIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
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
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpStatistics()
    }
    
    private func setUpStatistics() {
        longestStreak = try? trackerRecordDataProvider?.calculateLongestStreak()
        perfectDays = try? trackerRecordDataProvider?.calculatePerfectDays()
        habitsCompleted = try? trackerRecordDataProvider?.calculateTotalHabitsCompleted()
        averageHabitsPerDay = try? trackerRecordDataProvider?.calculateAverageHabitsPerDay()
        
        let hasData = longestStreak ?? 0 > 0 || perfectDays ?? 0 > 0 || habitsCompleted ?? 0 > 0 || averageHabitsPerDay ?? 0 > 0
        placeholderImage.isHidden = hasData
        placeholderLabel.isHidden = hasData
        tableView.isHidden = !hasData
        tableView.reloadData()
    }
}

//MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
}

//MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.statisticsCellIdentifier, for: indexPath) as? StatisticsCell else { return UITableViewCell() }
        let bestPeriodText = NSLocalizedString("statistics.bestPeriod", comment: "Text displayed on best period")
        let perfectDaysText = NSLocalizedString("statistics.perfectDays", comment: "Text displayed on perfect days")
        let habitsCompletedText = NSLocalizedString("statistics.habitsCompleted", comment: "Text displayed on completed trackers")
        let averageHabitsPerDayText = NSLocalizedString("statistics.averageHabitsPerDay", comment: "Text displayed on average value")
        let titles = [bestPeriodText, perfectDaysText, habitsCompletedText, averageHabitsPerDayText]
        let counts = [longestStreak, perfectDays, habitsCompleted, averageHabitsPerDay]
        if indexPath.row < titles.count && indexPath.row < counts.count {
            let title = titles[indexPath.row]
            let count = counts[indexPath.row] ?? 0
            cell.configureCell(with: title, count: count)
        }
        return cell
    }
}

//MARK: - TrackerRecordDataProviderDelegate
extension StatisticsViewController: TrackerRecordDataProviderDelegate {
    func didUpdate(_ update: TrackerRecordStoreUpdate) {
        setUpStatistics()
        tableView.reloadData()
    }
}

//MARK: - AutoLayout
extension StatisticsViewController {
    private func setupViews() {
        view.backgroundColor = .ypBackground
        [titleLabel,
         tableView, placeholderImage, placeholderLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            placeholderImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -273),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

//MARK: - Localize
extension StatisticsViewController {
    func localize() {
        let titleText = NSLocalizedString("statistics", comment: "Text displayed on title")
        titleLabel.text = titleText
    }
}
