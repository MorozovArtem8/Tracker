//  Created by Artem Morozov on 11.09.2024.


import UIKit

final class SplashScreenViewController: UIViewController {
    
    private var hasSeenOnboarding: Bool = {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        return hasSeenOnboarding
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        
        if !hasSeenOnboarding {
            let onboardingPageViewController = OnboardingPageViewController()
            addChild(onboardingPageViewController)
            
            if let tabBarController = children.first(where: { $0 is TabBarController }) as? TabBarController {
                view.insertSubview(onboardingPageViewController.view, aboveSubview: tabBarController.view)
            }
        }
       
    }
    
    private func addTabBar() {
        let tabBarController = TabBarController()
        addChild(tabBarController)
        view.addSubview(tabBarController.view)
        
        if let childView = tabBarController.view {
            childView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                childView.topAnchor.constraint(equalTo: view.topAnchor),
                childView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                childView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            ])
        }
        
        tabBarController.didMove(toParent: self)
    }
}
