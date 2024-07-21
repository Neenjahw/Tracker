
import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelect(category: TrackerCategory?)
}

//MARK: - CategoryViewController
final class CategoryViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let tableViewCornerRadius: CGFloat = 16
        static let placeholderLabelFontSize: CGFloat = 12
        static let addCategoryButtonFontSize: CGFloat = 16
        static let addCategoryButtonCornerRadius: CGFloat = 16
        static let textFieldCornerRadius: CGFloat = 16
        static let categoryCellCornerRadius: CGFloat = 16
    }
    
    //MARK: - Public Properties
    weak var delegate: CategoryViewControllerDelegate?
    
    //MARK: - Private properties
    private var selectedCategory: TrackerCategory? = nil
    
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
    
    //MARK: - Init
    init(delegate: CategoryViewControllerDelegate? = nil, selectedCategory: TrackerCategory? = nil) {
        self.delegate = delegate
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.categoryCellIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.layer.cornerRadius = UIConstants.tableViewCornerRadius
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholderTrackerView
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.placeholderLabelFontSize)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Привычки и события можно \n объединить по смыслу"
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.addCategoryButtonFontSize)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = UIConstants.addCategoryButtonCornerRadius
        button.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        setPlaceholderImage()
    }
    
    //MARK: - Private Methods
    private func setPlaceholderImage() {
        let trackerCategories = trackerCategoryDataProvider?.fetchCategories()
        let isEmpty = trackerCategories?.isEmpty ?? true
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
    }
    
    @objc private func didTapAddCategoryButton() {
        let addCategoryViewController = AddCategoryViewController()
        addCategoryViewController.delegate = self
        present(addCategoryViewController, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return trackerCategoryDataProvider?.numberOfSections ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setPlaceholderImage()
        return trackerCategoryDataProvider?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.categoryCellIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        guard let trackerCategory = trackerCategoryDataProvider?.object(at: indexPath) else { return UITableViewCell()}
        cell.textLabel?.text = trackerCategory.title
        
        if selectedCategory != nil && cell.textLabel?.text == selectedCategory?.title {
            cell.setCheckMark()
        } else {
            cell.removeCheckMark()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

//MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
            return
        }
        
        guard let trackerCategory = trackerCategoryDataProvider?.object(at: indexPath) else { return }
        selectedCategory = trackerCategory
        delegate?.didSelect(category: selectedCategory)
        cell.setCheckMark()
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
            return
        }
        cell.removeCheckMark()
    }
}

//MARK: - AddCategoryViewControllerDelegate
extension CategoryViewController: AddCategoryViewControllerDelegate {
    func add(category: TrackerCategory) {
        do {
            try trackerCategoryDataProvider?.createCategory(category)
        } catch {
            print("Не удалось создать категорию")
        }
    }
}

//MARK: - TrackerCategoryDataProviderDelegate
extension CategoryViewController: TrackerCategoryDataProviderDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        tableView.performBatchUpdates {
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(row: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            tableView.deleteRows(at: deletedIndexPaths, with: .automatic)
        }
    }
}

//MARK: - AutoLayout
extension CategoryViewController {
    private func initialize() {
        setupViews()
        setConstraints()
        setPlaceholderImage()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [titleLabel,
         tableView,
         placeholderImageView,
         placeholderLabel,
         addCategoryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            placeholderImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}


