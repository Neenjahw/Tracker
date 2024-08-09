
import UIKit

//MARK: - ColorsCollectionViewCell
final class ColorsCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let colorViewCornerRadius: CGFloat = 8
    }
    
    //MARK: - Static Properties
    static let colorsCollectionViewCellIdentifier = "ColorsCollectionViewCell"
    
    //MARK: - UIModels
    private lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = UIConstants.colorViewCornerRadius
        return view
    }()
    
    private lazy var colorsSelectedImageFrame: UIImageView = {
        let image = UIImageView()
        image.image = .colorSelectedFrame
        image.isHidden = true
        return image
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
    func updateColor(color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func updateColorFrame(color: UIColor, isHidden: Bool) {
        colorsSelectedImageFrame.tintColor = color
        colorsSelectedImageFrame.isHidden = isHidden
    }
}

//MARK: - AutoLayout
extension ColorsCollectionViewCell {
    
    private func setupViews() {
        [colorView,
         colorsSelectedImageFrame].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: frame.width - 12),
            colorView.widthAnchor.constraint(equalToConstant: frame.width - 12),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorsSelectedImageFrame.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorsSelectedImageFrame.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorsSelectedImageFrame.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorsSelectedImageFrame.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
