
import UIKit

//MARK: -
protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

//MARK: - CollectionViewCell
final class TrackerCell: UICollectionViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let trackerCardViewCornerRadius: CGFloat = 16
        static let emojiLabelCornerRadius: CGFloat = 12
        static let daysCountLabelFontSize: CGFloat = 12
        static let emojiLabelFontSize: CGFloat = 12
        static let trackerCardLabelFontSize: CGFloat = 12
        static let trackerDoneButtonCornerRadius: CGFloat = 17
    }
    //MARK: - Static Properties
    static let collectionCellIdentifier = "CollectionCell"
    
    //MARK: - Public Properties
    weak var delegate: TrackerCellDelegate?
    
    //MARK: - Private Properties
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    //MARK: - UIModels
    private lazy var trackerCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.trackerCardViewCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let trackerCardEmojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(white: 1, alpha: 0.3)
        label.layer.cornerRadius = UIConstants.emojiLabelCornerRadius
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.emojiLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerCardLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UIConstants.trackerCardLabelFontSize)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.daysCountLabelFontSize)
        label.text = "1 день"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerDoneButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.layer.cornerRadius = UIConstants.trackerDoneButtonCornerRadius
        button.addTarget(self, action: #selector(didTapTrackerDoneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public Methods
    func configure(with tracker: Tracker, isCompletedToday: Bool, at indexPath: IndexPath) {
        trackerCardLabel.text = tracker.name
        trackerCardView.backgroundColor = tracker.color
        trackerCardEmojiLabel.text = tracker.emoji
        updateDoneButton()
        self.isCompletedToday = isCompletedToday
        self.trackerId = tracker.id
        self.indexPath = indexPath
    }
    
    //MARK: - Private Methods
    private func updateDoneButton() {
        guard let trackerColor = trackerCardView.backgroundColor else { return }
        let image = isCompletedToday ? UIImage(resource: .trackerDone) : UIImage(resource: .trackerPlus)
        trackerDoneButton.setImage(image.withTintColor(trackerColor), for: .normal)
    }
    
    func setCompletedState(_ completed: Bool) {
        isCompletedToday = completed
        updateDoneButton()
    }
    
    @objc private func didTapTrackerDoneButton() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("No trackerId")
            return
        }
        if !isCompletedToday {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        }
    }
}

//MARK: - AutoLayout
extension TrackerCell {
    private func initialize() {
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        contentView.addSubview(trackerCardView)
        trackerCardView.addSubview(trackerCardEmojiLabel)
        trackerCardView.addSubview(trackerCardLabel)
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(trackerDoneButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            trackerCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerCardView.heightAnchor.constraint(equalToConstant: 90),
            
            trackerCardEmojiLabel.topAnchor.constraint(equalTo: trackerCardView.topAnchor, constant: 12),
            trackerCardEmojiLabel.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: 12),
            trackerCardEmojiLabel.widthAnchor.constraint(equalToConstant: 24),
            trackerCardEmojiLabel.heightAnchor.constraint(equalTo: trackerCardEmojiLabel.widthAnchor),
            
            trackerCardLabel.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: 12),
            trackerCardLabel.bottomAnchor.constraint(equalTo: trackerCardView.bottomAnchor, constant: -12),
            trackerCardLabel.trailingAnchor.constraint(equalTo: trackerCardView.trailingAnchor, constant: -12),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: trackerDoneButton.centerYAnchor),
            
            trackerDoneButton.widthAnchor.constraint(equalToConstant: 34),
            trackerDoneButton.heightAnchor.constraint(equalToConstant: 34),
            trackerDoneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            trackerDoneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            
        ])
    }
}
