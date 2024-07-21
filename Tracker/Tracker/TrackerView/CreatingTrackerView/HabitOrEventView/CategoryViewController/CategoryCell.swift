
import UIKit

//MARK: - CategoryCell
final class CategoryCell: UITableViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 17
    }
    
    //MARK: - Static properties
    static let categoryCellIdentifier = "categoryCell"
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public Methods
    public func setCheckMark() {
        checkmarkImageView.image = .categoryCheckmark
    }
    
    public func removeCheckMark() {
        checkmarkImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

//MARK: - AutoLayout
extension CategoryCell {
    private func initialize() {
        accessoryType = .none
        selectionStyle = .none
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .ypLightGray
        [titleLabel,
         checkmarkImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 75),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -21),
            checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
