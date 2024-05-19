
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.categoryCellIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = UIConstants.tableViewCornerRadius
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholderTrackerView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.placeholderLabelFontSize)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Привычки и события можно \n объединить по смыслу"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.addCategoryButtonFontSize)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = UIConstants.addCategoryButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
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
        if categories.count == 0 {
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
        }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CategoryCell
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
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addCategoryButton)
        tableView.delegate = self
        tableView.dataSource = self
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


