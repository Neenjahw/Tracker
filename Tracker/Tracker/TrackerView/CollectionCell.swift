
import UIKit

//MARK: - CollectionViewCell
final class CollectionCell: UICollectionViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let trackerCardViewCornerRadius: CGFloat = 16
        static let emojiLabelCornerRadius: CGFloat = 12
        static let daysCountLabelFontSize: CGFloat = 12
        static let emojiLabelFontSize: CGFloat = 12
        static let trackerCardLabelFontSize: CGFloat = 12
    }
    //MARK: - Static Properties
    static let collectionCellIdentifier = "CollectionCell"
    
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
    public func setTrackerCardLabel(for title: String) {
        trackerCardLabel.text = title
    }
    
    public func setTrackerCardView(for color: UIColor) {
        trackerCardView.backgroundColor = color
    }
    
    public func setTintColorTrackerDoneButton(for color: UIColor) {
        trackerDoneButton.setImage(.trackerPlus.withTintColor(color), for: .normal)
    }
    
    public func setTrackerCardEmojiLabel(for emoji: String) {
        trackerCardEmojiLabel.text = emoji
    }
    
    //MARK: - Private Methods
    @objc private func didTapTrackerDoneButton() {
        print("Did Taped didTapTrackerDoneButton")
    }
}

//MARK: - AutoLayout
extension CollectionCell {
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
