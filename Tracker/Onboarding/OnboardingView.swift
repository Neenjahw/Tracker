
import UIKit

//MARK: - OnboardingView
final class OnboardingView: UIView {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let pageLabelFontSize: CGFloat = 32
    }
    
    //MARK: - UIModels
    private lazy var pageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: UIConstants.pageLabelFontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pageButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector (didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    public func setPageLabelText(text: String) {
        pageLabel.text = text
    }
    
    public func setButton(text: String) {
        pageButton.setTitle(text, for: .normal)
    }
    
    public func setImageView(for image: UIImage) {
        pageImageView.image = image
    }
    
    public func set(transform: CGAffineTransform) {
        pageLabel.transform = transform
        pageButton.transform = transform
    }
    
    //MARK: - Private Methods
    @objc private func didTapButton() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
        let navigationController = UINavigationController(rootViewController: tabBarController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

//MARK: - AutoLayout
extension OnboardingView {
    
    private func setupViews() {
        addSubview(pageImageView)
        addSubview(pageLabel)
        addSubview(pageButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            pageImageView.topAnchor.constraint(equalTo: topAnchor),
            pageImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            pageLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 388),
            pageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            pageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            pageButton.widthAnchor.constraint(equalToConstant: 335),
            pageButton.heightAnchor.constraint(equalToConstant: 60),
            pageButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            pageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}
