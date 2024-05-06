
import UIKit

//MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let navLeftTitleLabelFontSize: CGFloat = 34
        static let trackerLabelFontSize: CGFloat = 12
    }
    
    //MARK: - Public Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    //MARK: - UIModels
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.M.yy"
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var placeholderImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = .placeholderTrackerView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var trackerLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.trackerLabelFontSize)
        label.text = "Что будем отслеживать?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Lifycylce
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        super.viewDidLoad()
        initialize()
    }
    
    //MARK: - Private Methods
}

//MARK: - AutoLayout
extension TrackerViewController {
    
    private func initialize() {
        setupForNavBar()
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        view.addSubview(placeholderImageView)
        view.addSubview(trackerLabel)
    }
    
    private func setupForNavBar() {
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .addTracker, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let searchController = UISearchController()
        navigationItem.searchController = searchController
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            placeholderImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -246),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            trackerLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor)
        ])
    }
}

