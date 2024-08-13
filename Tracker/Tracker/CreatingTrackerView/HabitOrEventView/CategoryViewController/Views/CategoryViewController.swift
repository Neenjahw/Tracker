
import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelect(category: TrackerCategory?)
}

//MARK: - CategoryViewController
final class CategoryViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
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
    private var viewModel: CategoryViewModel = CategoryViewModel()
    
    //MARK: - Init
    init(delegate: CategoryViewControllerDelegate? = nil, selectedCategory: TrackerCategory? = nil) {
        self.delegate = delegate
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
        bind()
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
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
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
        setupViews()
        setConstraints()
    }
    
    //MARK: - Private Methods
    private func bind() {
        viewModel.categoryCreated = { [weak self] insertedIndexPaths in
            guard let self = self else { return }
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
        }
//        
//        viewModel.categoryUpdated = { [weak self] updatedIndexPaths in
//            guard let self = self else { return }
//            tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
//        }
//        
//        viewModel.categoryDeleted = { [weak self] deletedIndexPaths in
//            guard let self = self else { return }
//            tableView.deleteRows(at: deletedIndexPaths, with: .automatic)
//        }
        viewModel.categoryCreatedSections = { [weak self] insertedSection in
            guard let self = self else { return }
            tableView.reloadSections(insertedSection, with: .automatic)
            tableView.reloadData()
        }
        
        viewModel.onErrorStateChange = { [weak self] errorMessage in
            guard let self = self else { return }
            presentAlertController(message: errorMessage)
        }
    }
    
    private func setPlaceholderImage() {
        let trackerCategories = viewModel.fetchCategories()
        let isEmpty = trackerCategories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
    }
    
    private func presentAlertController(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
//    private func configureCellCornerRadius(_ cell: UITableViewCell, at indexPath: IndexPath) {
//            switch indexPath.row {
//            case 0:
//                if viewModel.numberOfSections() == 1 {
//                    cell.layer.cornerRadius = UIConstants.categoryCellCornerRadius
//                    cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//                } else {
//                    cell.layer.cornerRadius = UIConstants.categoryCellCornerRadius
//                    cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//                }
//            case viewModel.numberOfSections() - 1:
//                cell.layer.cornerRadius = UIConstants.categoryCellCornerRadius
//                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//            default:
//                cell.layer.cornerRadius = 0
//                cell.layer.maskedCorners = []
//                cell.layer.masksToBounds = true
//            }
//            cell.layer.masksToBounds = true
//        }
//    
//    private func configureCellSeparatorInset(_ cell: UITableViewCell, at indexPath: IndexPath) {
//        if viewModel.numberOfSections() == 1 {
//            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: cell.bounds.width)
//        } else if indexPath.row == viewModel.numberOfSections() - 1 {
//            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: cell.bounds.width)
//        } else {
//            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        }
//    }
    
    @objc private func didTapAddCategoryButton() {
        let addCategoryViewController = AddCategoryViewController(isEditingCategory: false)
        addCategoryViewController.delegate = self
        present(addCategoryViewController, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        print("NumberOFSections in TableView = \(viewModel.numberOfSections())")
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setPlaceholderImage()
        print("numberOfRows in sections TableView = \(viewModel.numberOfRowsInSection(section))")
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.categoryCellIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        guard let trackerCategory = viewModel.editCategory(at: indexPath) else { return UITableViewCell() }
        print("Category at indexPath \(indexPath.row) = \(String(describing: viewModel.editCategory(at: indexPath)))")
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
        selectedCategory = viewModel.editCategory(at: indexPath)
        delegate?.didSelect(category: selectedCategory)
        
        tableView.reloadData()
        
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, 
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.count > 0 else { return nil }
        
        guard let trackerCategory = viewModel.editCategory(at: indexPath) else { return nil }
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(
                children: [
                    UIAction(title: "Редактировать") { _ in
                        let addCategoryViewController = AddCategoryViewController(delegate: self, category: trackerCategory, isEditingCategory: true)
                        self.present(addCategoryViewController, animated: true)
                    },
                    UIAction(title: "Удалить", attributes: .destructive) { _ in
                        let alertController = UIAlertController(
                            title: "",
                            message: "Эта категория точно не нужна?",
                            preferredStyle: .actionSheet)
                        
                        let deleteAction = UIAlertAction(
                            title: "Удалить",
                            style: .destructive) { _ in
//                                self.viewModel.deleteCategory(trackerCategory)
                            }
                        
                        let cancelAction = UIAlertAction(
                            title: "Отменить",
                            style: .cancel)
                        
                        alertController.addAction(deleteAction)
                        alertController.addAction(cancelAction)
                        
                        self.present(alertController, animated: true)
                    }
                ])
        })
    }
}

//MARK: - AddCategoryViewControllerDelegate
extension CategoryViewController: AddCategoryViewControllerDelegate {
    func update(_ category: TrackerCategory, with newTitle: String) {
//            viewModel.updateCategory(category, with: newTitle)
    }
    
    func add(category: TrackerCategory) {
        viewModel.create(category)
    }
}

//MARK: - AutoLayout
extension CategoryViewController {
    
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


