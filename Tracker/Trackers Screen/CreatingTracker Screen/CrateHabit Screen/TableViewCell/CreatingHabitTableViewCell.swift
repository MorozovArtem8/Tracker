//  Created by Artem Morozov on 08.08.2024.

import UIKit

final class CreatingHabitTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TableViewCell"
    private lazy var nameLabel = UILabel()
    private lazy var stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(nameLabel: String) {
        self.nameLabel.text = nameLabel
    }
}

//MARK: Configure UI
private extension CreatingHabitTableViewCell {
    func configureUI() {
        configureNameLabelAndImage()
        self.backgroundColor = UIColor("#E6E8EB", alpha: 0.3)
    }
    
    func configureNameLabelAndImage() {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor("#AEAFB4")
        
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        nameLabel.textColor = .black
        nameLabel.text = "12321421412"
        
        stackView = UIStackView(arrangedSubviews: [nameLabel, imageView])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    
        
        
    }
}
