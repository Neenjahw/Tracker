
import UIKit

//MARK: - CollectionViewCell
final class EmojiCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let emojiLabelFontSize: CGFloat = 32
        static let emojiLabelCornerRadius: CGFloat = 16
    }
    
    //MARK: - Static Properties
    static let emojiCollectionViewCellIdentifier = "EmojiCollectionViewCell"
    
    //MARK: - UIModels
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.emojiLabelFontSize, weight: .bold)
        label.layer.cornerRadius = UIConstants.emojiLabelCornerRadius
        label.layer.masksToBounds = true
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - AutoLayout
extension EmojiCollectionViewCell {
    private func initialize() {
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        [emojiLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.heightAnchor.constraint(equalToConstant: frame.width),
            emojiLabel.widthAnchor.constraint(equalToConstant: frame.width),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

