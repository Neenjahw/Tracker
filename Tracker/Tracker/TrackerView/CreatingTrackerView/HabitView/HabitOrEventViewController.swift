
import UIKit

//MARK: - HabitViewController
final class HabitOrEventViewController: UIViewController {
    
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
        static let habitOrEventCategoryCellCornerRadius: CGFloat = 16
        static let habitOrEventScheduleCellCornerRadius: CGFloat = 16
    }
    
    //MARK: - Public Properties
    var isHabit: Bool = false
    var scheduleCell: ScheduleCell?
    
    //MARK: - Private Properties
    private var selectedDays: [DayOfWeek] = []
    private var selectedCategories: [String] = []
    private let dataManager = DataManager.shared
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
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
        tableView.register(HabitOrEventCategoryCell.self, forCellReuseIdentifier: HabitOrEventCategoryCell.habitCategoryCellIdentifier)
        tableView.register(HabitOrEventScheduleCell.self, forCellReuseIdentifier: HabitOrEventScheduleCell.habitScheduleCellIdentifier)
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
        let textIsValid = textField.text?.isEmpty == false
        let categoriesAreSelected = !selectedCategories.isEmpty
        let daysAreSelected = !selectedDays.isEmpty
        
        let shouldEnableButton: Bool
        if isHabit {
            shouldEnableButton = textIsValid && categoriesAreSelected && daysAreSelected
        } else {
            shouldEnableButton = textIsValid && categoriesAreSelected
        }
        
        createButton.isEnabled = shouldEnableButton
        createButton.backgroundColor = shouldEnableButton ? .ypBlack : .ypGray
    }
    
    private func makeTracker() -> Tracker {
        let name = textField.text ?? ""
        let id = UUID()
        let schedule = selectedDays
        return Tracker(id: id,
                       name: name,
                       color: .ypBlue,
                       emoji: "⛑️",
                       schedule: schedule)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tracker = makeTracker()
        for category in selectedCategories {
            dataManager.add(category: TrackerCategory(title: category, trackers: [tracker]))
        }
        
        let tabBarController = TabBarController()
        let navigationController = UINavigationController(rootViewController: tabBarController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func didTapClearTextFieldButton() {
        textField.text = ""
        characterLimitLabel.isHidden = true
    }
    
    private func chooseHabitOrIrregularEvent() {
        if isHabit {
            titleLabel.text = "Новая привычка"
        } else {
            titleLabel.text = "Новое нерегулярное событие"
        }
        tableView.reloadData()
    }
}

//MARK: - UITextFieldDelegate
extension HabitOrEventViewController: UITextFieldDelegate {
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
extension HabitOrEventViewController: UITableViewDelegate {
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
extension HabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isHabit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isHabit {
            switch indexPath.row {
            case 0:
                return habitOrEventCategoryCell(for: indexPath, in: tableView, isLastCell: false)
            default:
                return habitOrEventScheduleCell(for: indexPath, in: tableView, isLastCell: true)
            }
        } else {
            return habitOrEventCategoryCell(for: indexPath, in: tableView, isLastCell: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    private func habitOrEventCategoryCell(for indexPath: IndexPath, in tableView: UITableView, isLastCell: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventCategoryCell.habitCategoryCellIdentifier, for: indexPath) as? HabitOrEventCategoryCell else {
            return UITableViewCell()
        }
        
        configureSeparator(for: cell, isLastCell: isLastCell)
        configureCornerRadius(for: cell, indexPath: indexPath)
        
        let selectedCategoriesString = selectedCategories.joined(separator: ", ")
        cell.changeCategoriesLabel(categories: selectedCategoriesString)
        return cell
    }
    
    private func habitOrEventScheduleCell(for indexPath: IndexPath, in tableView: UITableView, isLastCell: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventScheduleCell.habitScheduleCellIdentifier, for: indexPath) as? HabitOrEventScheduleCell else {
            return UITableViewCell()
        }
        configureSeparator(for: cell, isLastCell: isLastCell)
        configureCornerRadius(for: cell, indexPath: indexPath)
        
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
        return cell
    }
    
    private func configureSeparator(for cell: UITableViewCell, isLastCell: Bool) {
        if isLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 16)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    private func configureCornerRadius(for cell: UITableViewCell, indexPath: IndexPath) {
        let cornerRadius = UIConstants.habitOrEventCategoryCellCornerRadius
        
        if isHabit {
            switch indexPath.row {
            case 0:
                cell.layer.cornerRadius = cornerRadius
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case 1:
                cell.layer.cornerRadius = cornerRadius
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            default:
                cell.layer.cornerRadius = 0
                cell.layer.maskedCorners = []
            }
        } else {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.layer.masksToBounds = true
    }
}

//MARK: - CategoryViewControllerDelegate
extension HabitOrEventViewController: CategoryViewControllerDelegate {
    func didSelect(categories: [String]) {
        for category in categories {
            selectedCategories.append(category)
        }
        tableView.reloadData()
        updateCreateButtonAvailability()
    }
}

//MARK: - ScheduleViewControllerDelegate
extension HabitOrEventViewController: ScheduleViewControllerDelegate {
    func didSelect(days: [DayOfWeek]) {
        selectedDays = days
        tableView.reloadData()
        updateCreateButtonAvailability()
    }
}

//MARK: - AutoLayout
extension HabitOrEventViewController {
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
