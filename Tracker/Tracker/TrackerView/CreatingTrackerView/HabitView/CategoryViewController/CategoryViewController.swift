
import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelect(categories: [String])
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
    private var categories: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var selectedCategories: [String] = []
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.categoryCellIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.layer.cornerRadius = UIConstants.tableViewCornerRadius
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didSelect(categories: selectedCategories)
    }
    
    //MARK: - Private Methods
    private func setPlaceholderImage() {
        placeholderImageView.isHidden = !categories.isEmpty
        placeholderLabel.isHidden = !categories.isEmpty
    }
    
    @objc private func didTapAddCategoryButton() {
        let addCategoryViewController = AddCategoryViewController()
        addCategoryViewController.delegate = self
        present(addCategoryViewController, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setPlaceholderImage()
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.categoryCellIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

//MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configureCellCornerRadius(cell, at: indexPath)
        configureCellSeparatorInset(cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
            return
        }
        
        let category = categories[indexPath.row]
        if let index = selectedCategories.firstIndex(of: category) {
            selectedCategories.remove(at: index)
            cell.removeCheckMark()
        } else {
            selectedCategories.append(category)
            cell.setCheckMark()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func configureCellCornerRadius(_ cell: UITableViewCell, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if categories.count == 1 {
                cell.layer.cornerRadius = UIConstants.categoryCellCornerRadius
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.cornerRadius = UIConstants.categoryCellCornerRadius
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        case categories.count - 1:
            cell.layer.cornerRadius = UIConstants.categoryCellCornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
            cell.layer.masksToBounds = true
        }
        cell.layer.masksToBounds = true
    }
    
    private func configureCellSeparatorInset(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if categories.count == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: cell.bounds.width)
        } else if indexPath.row == categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: cell.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

//MARK: - AddCategoryViewControllerDelegate
extension CategoryViewController: AddCategoryViewControllerDelegate {
    func addCategory(nameOfCategory: String) {
        categories.append(nameOfCategory)
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderImageView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -276),
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


