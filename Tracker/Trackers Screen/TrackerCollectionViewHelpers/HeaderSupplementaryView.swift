//  Created by Artem Morozov on 31.07.2024.

import UIKit

final class HeaderSupplementaryView: UICollectionReusableView {
    let titleLabel = UILabel()
    
    private let color = Colors()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = color.textColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
