
import UIKit

//MARK: - ScheduleViewCellDelegate
protocol ScheduleViewCellDelegate: AnyObject {
    func switchStateChanged(isOn: Bool, for day: DayOfWeek?)
}

//MARK: - ScheduleViewCell
final class ScheduleCell: UITableViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 17
    }
    
    //MARK: - Static properties
    static let scheduleCellIdentifier = "ScheduleCell"
    
    //MARK: - Public Properties
    var dayOfWeek: DayOfWeek? {
        didSet {
            titleLabel.text = dayOfWeek?.rawValue
        }
    }
    
    weak var delegate: ScheduleViewCellDelegate?
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .ypBlue
        switchControl.addTarget(self, action: #selector(switchDidChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private Methods
    @objc private func switchDidChanged(_ sender: UISwitch) {
        delegate?.switchStateChanged(isOn: sender.isOn, for: dayOfWeek)
    }
}
//MARK: - AutoLayout
extension ScheduleCell {
    private func initialize() {
        accessoryType = .none
        selectionStyle = .none
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .ypLightGray
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
