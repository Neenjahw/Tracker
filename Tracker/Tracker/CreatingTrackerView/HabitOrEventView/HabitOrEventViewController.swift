
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
    private var tableViewTopConstraint: NSLayoutConstraint?
    
    private var selectedDays: [DayOfWeek] = []
    private var selectedCategory: TrackerCategory?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private let params: GeometricParams = {
        let params = GeometricParams(cellCount: 6,
                                     topInset: 24,
                                     leftInset: 18,
                                     bottomInset: 40,
                                     rightInset: 18,
                                     cellSpacing: 5)
        return params
    }()
    
    private let emoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [.ypRedCrad, .ypOrangeCard, .ypBlueCard, .ypPurpleCard, .ypGreenCard, .ypMagneticCard,
                                     .ypLightPinkCard, .ypLightBlueCard, .ypMintCard, .ypUltramarineCard, .ypPeachCard, .ypPinkCard,
                                     .ypLightPeachCard, .ypCornflowerBlueCard, .ypIndigoCard, .ypLightIndigoCard, .ypAmethystCard, .ypJadeCard]
    
    private lazy var trackerDataProvider: TrackerDataProviderProtocol? = {
        let trackerDataStore = TrackerStore()
        do {
            try trackerDataProvider = TrackerDataProvider(trackerStore:trackerDataStore,
                                                          delegate: self)
            return trackerDataProvider
        } catch {
            print("Данные не доступны")
            return nil
        }
    }()
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        label.textColor = .black
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
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
        textField.delegate = self
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
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.emojiCollectionViewCellIdentifier)
        collectionView.register(SupplementaryEmojiView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.tag = 1
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: ColorsCollectionViewCell.colorsCollectionViewCellIdentifier)
        collectionView.register(SupplementaryColorsView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.tag = 2
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
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
        setupViews()
        setConstraints()
        chooseHabitOrIrregularEvent()
    }
    
    //MARK: - Private Methods
    private func updateCreateButtonAvailability() {
        let textIsValid = textField.text?.isEmpty == false
        let categoriesAreSelected = selectedCategory != nil && !(selectedCategory!.title.isEmpty)
        let daysAreSelected = !selectedDays.isEmpty
        let emojiAreSelected = selectedEmoji != nil
        let colorAreSelected = selectedColor != nil
        let shouldEnableButton: Bool
        
        if isHabit {
            shouldEnableButton = textIsValid && categoriesAreSelected && daysAreSelected && emojiAreSelected && colorAreSelected
        } else {
            shouldEnableButton = textIsValid && categoriesAreSelected && emojiAreSelected && colorAreSelected
        }
        
        createButton.isEnabled = shouldEnableButton
        createButton.backgroundColor = shouldEnableButton ? .ypBlack : .ypGray
    }
    
    private func makeTracker() -> Tracker {
        let name = textField.text ?? ""
        let id = UUID()
        let today = Date()
        var schedule: [DayOfWeek] = []
        
        if isHabit {
            schedule = selectedDays
        } else {
            var filterWeekDay = Calendar.current.component(.weekday, from: today)
            if filterWeekDay == 1 {
                filterWeekDay = 7
            } else {
                filterWeekDay -= 1
            }
            if let selectedDayOfWeek = DayOfWeek(rawValue: filterWeekDay) {
                schedule.append(selectedDayOfWeek)
            }
        }
        
        let isHabit = isHabit ? true : false
        
        return Tracker(id: id,
                       name: name,
                       color: selectedColor ?? UIColor(white: 1, alpha: 1),
                       emoji: selectedEmoji ?? "",
                       schedule: schedule,
                       isHabit: isHabit)
    }
    
    @objc private func didTapCancelButton() {
        selectedDays.removeAll()
        selectedEmoji = nil
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        if let category = selectedCategory {
            do {
                try trackerDataProvider?.addTracker(makeTracker(),
                                                    for: category)
                print(category.trackers)
            } catch {
                print("Не удалось создать трекер для категории \(category)")
            }
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
            tableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }
        tableView.reloadData()
    }
    
    private func getCollectionHeight() -> CGFloat {
        let availableWidth = view.frame.width - params.paddingWidth
        let cellHeight =  availableWidth / CGFloat(params.cellCount)
        
        let num = cellHeight * 4.5
        let collectionSize = CGFloat(num)
        
        return collectionSize
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
            tableViewTopConstraint?.constant = 24
            return true
        } else {
            characterLimitLabel.isHidden = false
            tableViewTopConstraint?.constant = 48
            view.layoutIfNeeded()
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
            let categoryViewController = CategoryViewController(delegate: self, selectedCategory: selectedCategory)
            present(categoryViewController, animated: true)
            return
        default:
            let scheduleViewController = ScheduleViewController(delegate: self, selectedDays: selectedDays)
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
        
        if let selectedCategoriesString = selectedCategory?.title {
            cell.changeCategoriesLabel(categories: selectedCategoriesString)
        } else {
            cell.changeCategoriesLabel(categories: "")
        }
        return cell
    }
    
    private func habitOrEventScheduleCell(for indexPath: IndexPath, in tableView: UITableView, isLastCell: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventScheduleCell.habitScheduleCellIdentifier, for: indexPath) as? HabitOrEventScheduleCell else {
            return UITableViewCell()
        }
        configureSeparator(for: cell, isLastCell: isLastCell)
        configureCornerRadius(for: cell, indexPath: indexPath)
        
        let sortedDays = selectedDays.sorted(by: { $0.rawValue < $1.rawValue })
        let selectedDaysString = sortedDays.map { day in
            switch day {
            case .monday:
                return "Пн"
            case .tuesday:
                return "Вт"
            case .wednesday:
                return "Ср"
            case .thursday:
                return "Чт"
            case .friday:
                return "Пт"
            case .saturday:
                return "Сб"
            case .sunday:
                return "Вс"
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

//MARK: - UICollectionViewDataSource
extension HabitOrEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return emoji.count
        case 2:
            return colors.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.emojiCollectionViewCellIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.updateEmojiLabel(emoji: emoji[indexPath.row])
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionViewCell.colorsCollectionViewCellIdentifier, for: indexPath) as? ColorsCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.updateColor(color: colors[indexPath.row])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        switch collectionView.tag {
        case 1:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryEmojiView
            view?.updateTitleLabel(text: "Emoji")
            return view!
        case 2:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryColorsView
            view?.updateTitleLabel(text: "Цвет")
            return view!
        default:
            return UICollectionReusableView()
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension HabitOrEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: collectionView.frame.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

//MARK: - UICollectionViewDelegate
extension HabitOrEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1:
            let selectedEmoji = emoji[indexPath.row]
            if let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.updateEmojiLabelBackground(color: .ypGraySelectEmoji)
            }
            self.selectedEmoji = selectedEmoji
            updateCreateButtonAvailability()
        case 2:
            let selectedColor = colors[indexPath.row]
            if let cell = colorsCollectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell {
                cell.updateColorFrame(color: colors[indexPath.row], isHidden: false)
                self.selectedColor = selectedColor
                updateCreateButtonAvailability()
            }
        default:
            print("")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1:
            if let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.updateEmojiLabelBackground(color: .clear)
            }
            self.selectedEmoji = nil
            updateCreateButtonAvailability()
        case 2:
            if let cell = colorsCollectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell {
                cell.updateColorFrame(color: colors[indexPath.row], isHidden: true)
            }
            self.selectedColor = nil
            updateCreateButtonAvailability()
        default:
            print("")
        }
    }
}

//MARK: - CategoryViewControllerDelegate
extension HabitOrEventViewController: CategoryViewControllerDelegate {
    func didSelect(category: TrackerCategory?) {
        selectedCategory = category
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

//MARK: - TrackerDataProviderDelegate
extension HabitOrEventViewController: TrackerDataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) { }
}

//MARK: - AutoLayout
extension HabitOrEventViewController {
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [titleLabel,
         scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        [textField,
         characterLimitLabel,
         tableView,
         emojiCollectionView,
         colorsCollectionView,
         cancelButton,
         createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraints() {
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalToConstant: 400),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            characterLimitLabel.heightAnchor.constraint(equalToConstant: 32),
            characterLimitLabel.widthAnchor.constraint(equalToConstant: 286),
            characterLimitLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            characterLimitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableViewTopConstraint!,
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiCollectionView.heightAnchor.constraint(equalToConstant: getCollectionHeight()),
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            colorsCollectionView.heightAnchor.constraint(equalToConstant: getCollectionHeight()),
            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 24),
            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 24),
            createButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
