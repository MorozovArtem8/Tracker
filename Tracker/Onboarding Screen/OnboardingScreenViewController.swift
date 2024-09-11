//  Created by Artem Morozov on 11.09.2024.


import UIKit

class OnboardingScreenViewController: UIViewController {
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let image: UIImage
    private let text: String
    
    init(image: UIImage, text: String) {
        self.text = text
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = image
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        view.addSubview(textLabel)
        
        let screenHeight = UIScreen.main.bounds.height
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: screenHeight / 1.9),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

}
