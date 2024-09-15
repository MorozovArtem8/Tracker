//  Created by Artem Morozov on 11.09.2024.


import UIKit

protocol OnboardingScreenDelegate: AnyObject {
    func removeOnboarding()
}

final class OnboardingPageViewController: UIPageViewController, OnboardingScreenDelegate {
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let dismissOnboarding: (() -> Void)
    
    private lazy var pages: [UIViewController] = {
        let blueOnboardingScreen = OnboardingScreenViewController(image: UIImage(named: "1") ?? UIImage(), text: "Отслеживайте только то, что хотите", delegate: self)
        let redOnboardingScreen = OnboardingScreenViewController(image: UIImage(named: "2") ?? UIImage(), text: "Даже если это не литры воды и йога", delegate: self)
        return [blueOnboardingScreen, redOnboardingScreen]
    }()
    
    init(dismissOnboarding: @escaping (() -> Void)) {
        self.dismissOnboarding = dismissOnboarding
        super .init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func removeOnboarding() {
        dismissOnboarding()
    }
}

//MARK: UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {return nil}
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {return nil}
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

//MARK: Configure UI

private extension OnboardingPageViewController {
    func configureUI() {
        dataSource = self
        delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        
        configureElements()
    }
    
    func configureElements() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
}
