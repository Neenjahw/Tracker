
import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelect(days: [DayOfWeek])
}

//MARK: - ScheduleViewController
final class ScheduleViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let tableViewCornerRadius: CGFloat = 16
        static let doneButtonFontSize: CGFloat = 16
        static let doneButtonCornerRadius: CGFloat = 16
        static let firstCellCornerRadius: CGFloat = 16
        static let lastCellCornerRadius: CGFloat = 16
    }
    
    //MARK: - Public Properties
    weak var delegate: ScheduleViewControllerDelegate?
    
    private var selectedDays: [DayOfWeek] = []
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.scheduleCellIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.layer.cornerRadius = UIConstants.tableViewCornerRadius
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.doneButtonFontSize, weight: .regular)
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = UIConstants.doneButtonCornerRadius
        button.addTarget(self, action: #selector(backToHabitViewController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    //MARK: - Private Methods
    @objc private func backToHabitViewController() {
        delegate?.didSelect(days: selectedDays)
        dismiss(animated: true)
    }
}

//MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayOfWeek.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.scheduleCellIdentifier, for: indexPath) as? ScheduleCell else {
                return UITableViewCell()
            }
            cell.layer.cornerRadius = UIConstants.firstCellCornerRadius
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.delegate = self
            let dayOfWeek = DayOfWeek.allCases[indexPath.row]
            cell.dayOfWeek = dayOfWeek
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            return cell
        case 6:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.scheduleCellIdentifier, for: indexPath) as? ScheduleCell else {
                return UITableViewCell()
            }
            cell.layer.cornerRadius = UIConstants.lastCellCornerRadius
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.delegate = self
            let dayOfWeek = DayOfWeek.allCases[indexPath.row]
            cell.dayOfWeek = dayOfWeek
            cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 16)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.scheduleCellIdentifier, for: indexPath) as? ScheduleCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            let dayOfWeek = DayOfWeek.allCases[indexPath.row]
            cell.dayOfWeek = dayOfWeek
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

//MARK: - ScheduleViewCellDelegate
extension ScheduleViewController: ScheduleViewCellDelegate {
    func switchStateChanged(isOn: Bool, for day: DayOfWeek?) {
        guard let day = day else { return }
        if isOn {
            selectedDays.append(day)
        } else {
            if let index = selectedDays.firstIndex(of: day) {
                selectedDays.remove(at: index)
            }
        }
    }
}

//MARK: - AutoLayout
extension ScheduleViewController {
    private func initialize() {
        tableView.dataSource = self
        tableView.delegate = self
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
