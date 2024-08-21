
import UIKit

//MARK: - TabBarViewController
final class TabBarController: UITabBarController {
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBackground
        tabBar.isTranslucent = false
        
        let trackersText = NSLocalizedString("trackers", comment: "Text displayed on trackers")
        let statisticsText = NSLocalizedString("statistics", comment: "Text displayed on statistics")
        
        let trackerViewController = UINavigationController(rootViewController: TrackerListViewController())
        let statisticsViewController = StatisticsViewController()
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: trackersText,
            image: .trackerTabBarLogo,
            selectedImage: .trackerTabBarLogoSelected)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: statisticsText,
            image: .statisticsTabBarLogo,
            selectedImage: .statisticsTabBarLogoSelected)
        
        self.viewControllers = [trackerViewController, statisticsViewController]
        self.addTopBorder(color: UIColor.gray, thickness: 0.5)
    }
}

//MARK: - TopBorderTabBar
extension TabBarController {
    private func addTopBorder(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: thickness)
        tabBar.layer.addSublayer(border)
    }
}

