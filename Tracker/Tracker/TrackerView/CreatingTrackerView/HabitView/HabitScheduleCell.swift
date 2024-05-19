
import UIKit

//MARK: - ScheduleCell
final class HabitScheduleCell: UITableViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 17
    }
    
    //MARK: - Static properties
    static let habitScheduleCellIdentifier = "ScheduleCell"
    static let selectedDaysNotification = Notification.Name("selectedDaysNotification")
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysLabel: UILabel = {
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
    
    //MARK: - Public Methods
    public func changeDaysLabel(days: String) {
        if days.components(separatedBy: ", ").count == 7 {
            daysLabel.text = "Каждый день"
        } else {
            daysLabel.text = days
        }
    }
}

//MARK: - AutoLayout
extension HabitScheduleCell {
    private func initialize() {
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .ypLightGray
        addSubview(titleLabel)
        addSubview(daysLabel)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            daysLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
}
