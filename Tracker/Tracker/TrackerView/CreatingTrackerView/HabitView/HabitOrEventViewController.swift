
import UIKit

//MARK: - HabitViewController
final class HabitViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let cancelButtonFontSize: CGFloat = 16
        static let cancelButtonCornerRadius: CGFloat = 16
        static let createButtonFontSize: CGFloat = 16
        static let createButtonCornerRadius: CGFloat = 16
        static let textFieldCornerRadius: CGFloat = 16
        static let characterLimitLabelFontSize: CGFloat = 17
        static let tableViewCornerRadius: CGFloat = 16
        static let habitCategoryCellCornerRadius: CGFloat = 16
        static let habitScheduleCellCornerRadius: CGFloat = 16
    }
    
    //MARK: - Public Properties
    var scheduleCell: ScheduleCell?
    
    //MARK: - Private Properties
    private var selectedDays: [DayOfWeek] = []
    private var trackers: [Tracker] = []
    private var selectedCategories: [String] = []
    private let dataManager = DataManager.shared
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray
        textField.placeholder = "Введите название трекера"
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(.xMarkButton, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        clearButton.addTarget(self, action: #selector(didTapClearTextFieldButton), for: .touchUpInside)
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: clearButton.frame.width + 12, height: clearButton.frame.height))
        rightPaddingView.addSubview(clearButton)
        textField.rightView = rightPaddingView
        textField.rightViewMode = .whileEditing
        
        textField.layer.cornerRadius = UIConstants.textFieldCornerRadius
        return textField
    }()
    
    private lazy var characterLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: UIConstants.characterLimitLabelFontSize)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HabitCategoryCell.self, forCellReuseIdentifier: HabitCategoryCell.habitCategoryCellIdentifier)
        tableView.register(HabitScheduleCell.self, forCellReuseIdentifier: HabitScheduleCell.habitScheduleCellIdentifier)
        tableView.bounces = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.cancelButtonFontSize)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = UIConstants.cancelButtonCornerRadius
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.createButtonFontSize)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.layer.cornerRadius = UIConstants.createButtonCornerRadius
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    //MARK: - Private Methods
    private func updateCreateButtonAvailability() {
        if let text = textField.text, !text.isEmpty, !selectedCategories.isEmpty, !selectedDays.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    //TODO: В следуюищих спринтах
    //    private func makeTrackerCategory(with title: String, trackers: [Tracker]) -> TrackerRecord {
    //    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
        let navigationController = UINavigationController(rootViewController: tabBarController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    @objc private func didTapClearTextFieldButton() {
        textField.text = ""
        characterLimitLabel.isHidden = true
    }
}

//MARK: - UITextFieldDelegate
extension HabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        
        let maxLength = 38
        
        if newText.count <= maxLength {
            characterLimitLabel.isHidden = true
            return true
        } else {
            characterLimitLabel.isHidden = false
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateCreateButtonAvailability()
        return true
    }
}

//MARK: - UITableViewDelegate
extension HabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let categoryViewController = CategoryViewController()
            categoryViewController.delegate = self
            present(categoryViewController, animated: true)
            return
        default:
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
        }
    }
}

//MARK: - UITableViewDataSource
extension HabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return habitCategoryCell(for: indexPath, in: tableView)
        default:
            return habitScheduleCell(for: indexPath, in: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    private func habitCategoryCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitCategoryCell.habitCategoryCellIdentifier, for: indexPath) as? HabitCategoryCell else {
            return UITableViewCell()
        }
        cell.layer.cornerRadius = UIConstants.habitCategoryCellCornerRadius
        cell.layer.masksToBounds = true
        cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let selectedCategoriesString = selectedCategories.joined(separator: ", ")
        cell.changeCategoriesLabel(categories: selectedCategoriesString)
        return cell
    }

    private func habitScheduleCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitScheduleCell.habitScheduleCellIdentifier, for: indexPath) as? HabitScheduleCell else {
            return UITableViewCell()
        }
        cell.layer.cornerRadius = UIConstants.habitScheduleCellCornerRadius
        cell.layer.masksToBounds = true
        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        let selectedDaysString = selectedDays.map { day in
            switch day {
            case .monday:
                return("Пн")
            case .tuesday:
                return("Вт")
            case .wednesday:
                return("Ср")
            case .thursday:
                return("Чт")
            case .friday:
                return("Пт")
            case .saturday:
                return("Сб")
            case .sunday:
                return("Вс")
            }
        }.joined(separator: ", ")
        cell.changeDaysLabel(days: selectedDaysString)
        cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 16)
        return cell
    }
}

//MARK: - CategoryViewControllerDelegate
extension HabitViewController: CategoryViewControllerDelegate {
    func didSelect(categories: [String]) {
        for category in categories {
            selectedCategories.append(category)
        }
        tableView.reloadData()
        updateCreateButtonAvailability()
    }
}

//MARK: - ScheduleViewControllerDelegate
extension HabitViewController: ScheduleViewControllerDelegate {
    func didSelect(days: [DayOfWeek]) {
        selectedDays = days
        tableView.reloadData()
        updateCreateButtonAvailability()
    }
}

//MARK: - AutoLayout
extension HabitViewController {
    private func initialize() {
        setupViews()
        setConstraints()
        textField.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [titleLabel,
         textField,
         characterLimitLabel,
         tableView,
         cancelButton,
         createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            characterLimitLabel.heightAnchor.constraint(equalToConstant: 32),
            characterLimitLabel.widthAnchor.constraint(equalToConstant: 286),
            characterLimitLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            characterLimitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: characterLimitLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 24),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 24),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
