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
        let tabBarSeparator = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1))
        tabBarSeparator.backgroundColor = UIColor("AEAFB4")
        tabBar.addSubview(tabBarSeparator)
        setViewControllers([tabBarItem0, tabBarItem1], animated: true)
    }
    
    private func configureNavigationController(rootViewController: UIViewController, title: String, image: UIImage?) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.viewControllers.first?.navigationItem.title = title
        
        let font = UIFont.systemFont(ofSize: 34, weight: .bold)
        navigationController.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor("#1A1B22")
        ]
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image ?? UIImage()
        
        return navigationController
    }
}
