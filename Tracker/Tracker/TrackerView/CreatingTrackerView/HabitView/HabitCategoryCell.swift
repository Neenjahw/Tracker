
import UIKit

//MARK: - CategoryCell
final class HabitCategoryCell: UITableViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 17
    }
    
    //MARK: - Static properties
    static let habitCategoryCellIdentifier = "CategoryCell"
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Категория"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoriesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public Properties
    public func changeCategoriesLabel(categories: String) {
        categoriesLabel.text = categories
    }
}

//MARK: - AutoLayout
extension HabitCategoryCell {
    private func initialize() {
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .ypLightGray
        addSubview(titleLabel)
        addSubview(categoriesLabel)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            categoriesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoriesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
}
