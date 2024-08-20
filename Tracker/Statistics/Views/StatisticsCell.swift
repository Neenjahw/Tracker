import UIKit

//MARK: - StatisticsCell
final class StatisticsCell: UITableViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 12
        static let countLabelFontSize: CGFloat = 34
    }
    
    //MARK: - Static properties
    static let statisticsCellIdentifier = "statisticsCell"
    
    //MARK: - UIModels
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: UIConstants.countLabelFontSize)
        label.textColor = .label
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: UIConstants.titleLabelFontSize)
        label.textColor = .label
        return label
    }()
    
    private lazy var gradientBorderView: GradientBorderView = {
        let view = GradientBorderView()
        return view
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
        selectionStyle = .none
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    //MARK: - Public Methods
    func configureCell(with title: String, count: Int) {
        self.titleLabel.text = title
        self.countLabel.text = String(count)
    }
}

//MARK: - AutoLayout
extension StatisticsCell {
    private func setupViews() {
        [gradientBorderView, 
         titleLabel,
         countLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraints() {
        contentView.backgroundColor = .ypBackground
        
        NSLayoutConstraint.activate([
            gradientBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            countLabel.topAnchor.constraint(equalTo: gradientBorderView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: gradientBorderView.bottomAnchor, constant: -12)
        ])
    }
}
