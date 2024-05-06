
import UIKit

//MARK: - TabBarViewController
final class TabBarController: UITabBarController {
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tabBar.isTranslucent = false
        
        let trackerViewController = TrackerViewController()
        let statisticsViewController = StatisticsViewController()
        let navigationController = UINavigationController(rootViewController: trackerViewController)
        
        trackerViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: .trackerTabBarLogo, selectedImage: .trackerTabBarLogoSelected)
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика", image: .statisticsTabBarLogo, selectedImage: .statisticsTabBarLogoSelected)
        self.viewControllers = [navigationController, statisticsViewController]
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
