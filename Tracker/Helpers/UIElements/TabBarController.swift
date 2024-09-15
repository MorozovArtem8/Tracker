//  Created by Artem Morozov on 26.07.2024.

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTabBar()
    }
    
    private func createTabBar() {
        let trackerViewController = TrackerViewController()
        let statisticViewController = StatisticViewController()
        
        let tabBarItem0 = configureNavigationController(rootViewController: trackerViewController, title: "Трекеры", image: UIImage(named: "TrackerIconNotActive"))
        let tabBarItem1 = configureNavigationController(rootViewController: statisticViewController, title: "Статистика", image: UIImage(named: "StatisticIconNotActive"))
        tabBar.tintColor = UIColor("3772E7")
        tabBar.unselectedItemTintColor = UIColor("AEAFB4")
        tabBar.barTintColor = .white
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor("AEAFB4").cgColor
        setViewControllers([tabBarItem0, tabBarItem1], animated: false)
    }
    
    private func configureNavigationController(rootViewController: UIViewController, title: String, image: UIImage?) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationItem.largeTitleDisplayMode = .automatic
        navigationController.viewControllers.first?.navigationItem.title = title
        
        let largeFont = UIFont.systemFont(ofSize: 34, weight: .bold)
        navigationController.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: largeFont,
            NSAttributedString.Key.foregroundColor: UIColor("#1A1B22")
        ]
        
        let normalFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
                navigationController.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.font: normalFont,
                    NSAttributedString.Key.foregroundColor: UIColor("#1A1B22")
                ]
        
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image ?? UIImage()
        
        return navigationController
    }
}
