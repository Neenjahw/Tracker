
import UIKit

//MARK: - AddCategoryViewControllerDelegate
protocol AddCategoryViewControllerDelegate: NSObject {
    func add(category: TrackerCategory)
    func update(_ category: TrackerCategory, with newTitle: String)
}

//MARK: - CategoryViewController
final class AddCategoryViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let createButtonFontSize: CGFloat = 16
        static let createButtonCornerRadius: CGFloat = 16
        static let textFieldCornerRadius: CGFloat = 16
    }
    
    //MARK: - Public Properties
    weak var delegate: AddCategoryViewControllerDelegate?
    private var category: TrackerCategory?
    private var isEditingCategory: Bool?
    
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
        textField.placeholder = "Введите название категории"
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.delegate = self
        
        textField.layer.cornerRadius = UIConstants.textFieldCornerRadius
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.createButtonFontSize)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.layer.cornerRadius = UIConstants.createButtonCornerRadius
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        button.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }, for: .normal)
        button.setTitleColor(.white, for: .disabled)
        return button
    }()
    
    init(delegate: AddCategoryViewControllerDelegate? = nil, category: TrackerCategory? = nil, isEditingCategory: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.category = category
        self.isEditingCategory = isEditingCategory
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        changeTitleForEditingCategory()
        textField.text = category?.title
        setTapGesture()
    }
    
    //MARK: - Private Methods
    private func changeTitleForEditingCategory() {
        if isEditingCategory ?? false {
            titleLabel.text = "Редактирование категории"
        } else {
            titleLabel.text = "Новая категория"
        }
    }
    
    private func setTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapCreateButton() {
        guard let title = textField.text, !title.isEmpty else { return }

        if let category = category {
            delegate?.update(category, with: title)
        } else {
            let newCategory = TrackerCategory(title: title, trackers: [])
            delegate?.add(category: newCategory)
        }
        dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - AutoLayout
extension AddCategoryViewController {
    
    private func setupViews() {
        view.backgroundColor = .ypBackground
        [titleLabel,
         textField,
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
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}

