
import UIKit

//MARK: - ScheduleCell
final class HabitOrEventScheduleCell: UITableViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 17
    }
    
    //MARK: - Static properties
    static let habitScheduleCellIdentifier = "ScheduleCell"
    static let selectedDaysNotification = Notification.Name("selectedDaysNotification")
    
    //MARK: - Private Properties
    private var titleLabelTopConstraint: NSLayoutConstraint?
    private var titleLabelCenterYConstraint: NSLayoutConstraint?
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public Methods
    public func changeDaysLabel(days: String) {
        if days.components(separatedBy: ", ").count == 7 {
            daysLabel.text = "Каждый день"
        } else {
            daysLabel.text = days
        }
        updateTitleLabelConstraints()
    }
    
    private func updateTitleLabelConstraints() {
        if let text = daysLabel.text, !text.isEmpty {
            titleLabelCenterYConstraint?.isActive = false
            titleLabelTopConstraint?.isActive = true
        } else {
            titleLabelTopConstraint?.isActive = false
            titleLabelCenterYConstraint?.isActive = true
        }
        setNeedsLayout()
    }
}

//MARK: - AutoLayout
extension HabitOrEventScheduleCell {
    
    private func setupViews() {
        backgroundColor = .ypLightGray
        [titleLabel,
         daysLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setConstraints() {
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        titleLabelCenterYConstraint = titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            daysLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
        updateTitleLabelConstraints()
    }
}
