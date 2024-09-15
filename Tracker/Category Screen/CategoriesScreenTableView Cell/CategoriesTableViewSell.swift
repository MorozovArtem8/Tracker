//  Created by Artem Morozov on 13.09.2024.


import UIKit

final class CategoriesTableViewSell: UITableViewCell {
    static let reuseIdentifier = "CategoriesTableViewCell"
    
    private lazy var nameLabel = UILabel()
    private lazy var isActiveImage = UIImageView()
    private lazy var stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(categoryCell: CategoryCell) {
        self.nameLabel.text = categoryCell.title
        if let cellIsActive = categoryCell.isActive {
            isActiveImage.image = cellIsActive ? UIImage(systemName: "checkmark") : nil
        }
    }
    
    func didTapCell(_ cellIsActive: Bool) {
        isActiveImage.image = cellIsActive ? UIImage(systemName: "checkmark") : nil
    }
}

//MARK: Configure UI

private extension CategoriesTableViewSell {
    func configureUI() {
        configureLabel()
        self.backgroundColor = UIColor("#E6E8EB", alpha: 0.3)
    }
    
    func configureLabel() {
        isActiveImage.contentMode = .scaleAspectFit
        isActiveImage.tintColor = UIColor("#3772E7")
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = .black
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        stackView = UIStackView(arrangedSubviews: [nameLabel, spacer, isActiveImage])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: 10)
        ])
    }
}
