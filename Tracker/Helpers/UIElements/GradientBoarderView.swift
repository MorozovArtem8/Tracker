//  Created by Artem Morozov on 25.09.2024.


import UIKit

final class GradientBoarderView: UIView {
    private var gradientLayer = CAGradientLayer()
    private let boarderWidth: CGFloat = 2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradientLayer() {
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor("#007BFA").cgColor, UIColor("#46E69D").cgColor, UIColor("#FD4C49").cgColor]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.cornerRadius = 16
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = boarderWidth
        gradientLayer.mask = maskLayer
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.mask?.frame = bounds
        (gradientLayer.mask as? CAShapeLayer)?.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}

