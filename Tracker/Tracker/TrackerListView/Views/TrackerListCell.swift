
import UIKit

//MARK: - TrackerCellDelegate
protocol TrackerListCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

//MARK: - TrackerCell
final class TrackerListCell: UICollectionViewCell {
    
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
    weak var delegate: TrackerListCellDelegate?
    
    //MARK: - Private Properties
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    //MARK: - UIModels
    private lazy var trackerCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.trackerCardViewCornerRadius
        return view
    }()
    
    private let trackerCardEmojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(white: 1, alpha: 0.3)
        label.layer.cornerRadius = UIConstants.emojiLabelCornerRadius
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.emojiLabelFontSize)
        return label
    }()
    
    private lazy var trackerCardLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UIConstants.trackerCardLabelFontSize)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.daysCountLabelFontSize)
        label.text = "1 день"
        return label
    }()
    
    private lazy var trackerDoneButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.layer.cornerRadius = UIConstants.trackerDoneButtonCornerRadius
        button.addTarget(self, action: #selector(didTapTrackerDoneButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public Methods
    func configure(with tracker: Tracker, isCompletedToday: Bool, completedDays: Int, at indexPath: IndexPath) {
        trackerCardLabel.text = tracker.name
        trackerCardView.backgroundColor = tracker.color
        trackerCardEmojiLabel.text = tracker.emoji
        daysCountLabel.text = pluralizeDays(completedDays)
        self.isCompletedToday = isCompletedToday
        self.trackerId = tracker.id
        self.indexPath = indexPath
        updateDoneButton()
    }
    
    func setCompletedState(_ completed: Bool) {
        isCompletedToday = completed
        updateDoneButton()
    }
    
    //MARK: - Private Methods
    private func updateDoneButton() {
        guard let trackerColor = trackerCardView.backgroundColor else { return }
        let baseImage = isCompletedToday ? UIImage(resource: .trackerDone).withTintColor(trackerColor) : UIImage(resource: .trackerPlus)
        
        if isCompletedToday {
            let overlayImage = UIImage(resource: .trackerCheckmark).withTintColor(.white).withRenderingMode(.alwaysTemplate)
            if let combined = combinedImage(baseImage: baseImage, overlayImage: overlayImage, overlayScale: 1.2) {
                trackerDoneButton.setImage(combined, for: .normal)
            }
        } else {
            trackerDoneButton.setImage(baseImage.withTintColor(trackerColor), for: .normal)
        }
    }
    
    private func combinedImage(baseImage: UIImage, overlayImage: UIImage, overlayScale: CGFloat) -> UIImage? {
        let size = baseImage.size
        let overlaySize = CGSize(width: overlayImage.size.width * overlayScale, height: overlayImage.size.height * overlayScale)
        let overlayOrigin = CGPoint(x: (size.width - overlaySize.width) / 2, y: (size.height - overlaySize.height) / 2)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            baseImage.draw(in: CGRect(origin: .zero, size: size))
            overlayImage.draw(in: CGRect(origin: overlayOrigin, size: overlaySize))
        }
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 2) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
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
extension TrackerListCell {
    
    private func setupViews() {
        [trackerCardView,
         daysCountLabel,
         trackerDoneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        [trackerCardEmojiLabel,
         trackerCardLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            trackerCardView.addSubview($0)
        }
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
