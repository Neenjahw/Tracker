
import UIKit

//MARK: - CreatingTrackerViewController
final class CreatingTrackerViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let createHabitButtonTitleLabelFontSize: CGFloat = 16
        static let createIrregularEventButtonTitleLabelFontSize: CGFloat = 16
        static let createHabitButtonCornerRadius: CGFloat = 16
        static let createIrregularEventButtonCornerRadius: CGFloat = 16
    }
    
    //MARK: - UIModels
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        label.textColor = .label
        return label
    }()
    
    private lazy var createHabitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.createHabitButtonTitleLabelFontSize, weight: .regular)
        button.setTitle("Привычка", for: .normal)
        button.layer.cornerRadius = UIConstants.createHabitButtonCornerRadius
        button.addTarget(self, action: #selector(didTapCreateHabitButton), for: .touchUpInside)
        button.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }, for: .normal)
        return button
    }()
    
    private lazy var createIrregularEventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.createIrregularEventButtonTitleLabelFontSize, weight: .regular)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.layer.cornerRadius = UIConstants.createIrregularEventButtonCornerRadius
        button.addTarget(self, action: #selector(didTapCreateIrregularEventButton), for: .touchUpInside)
        button.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }, for: .normal)
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
    }
    
    //MARK: - Private Methods
    @objc private func didTapCreateHabitButton() {
        let habitViewController = HabitOrEventViewController(isEditingTracker: false)
        habitViewController.isHabit = true
        present(habitViewController, animated: true)
    }
    
    @objc private func didTapCreateIrregularEventButton() {
        let habitViewController = HabitOrEventViewController(isEditingTracker: false)
        habitViewController.isHabit = false
        present(habitViewController, animated: true)
    }
}

//MARK: - AutoLayout
extension CreatingTrackerViewController {
    
    private func setupViews() {
        view.backgroundColor = .ypBackground
        [titleLabel,
         createHabitButton,
         createIrregularEventButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createHabitButton.heightAnchor.constraint(equalToConstant: 60),
            createHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -323),
            createHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            createIrregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            createIrregularEventButton.topAnchor.constraint(equalTo: createHabitButton.bottomAnchor, constant: 16),
            createIrregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createIrregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}
