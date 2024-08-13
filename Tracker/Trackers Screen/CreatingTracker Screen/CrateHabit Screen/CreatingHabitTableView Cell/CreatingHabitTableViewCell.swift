//  Created by Artem Morozov on 08.08.2024.

import UIKit

final class CreatingHabitTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CreatingHabitTableViewCellReuseIdentifier"
    private lazy var nameLabel = UILabel()
    private lazy var subLabel = UILabel()
    private lazy var stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(nameLabel: String, subLabel: String?) {
        self.nameLabel.text = nameLabel
        guard let subLabel = subLabel else {
            self.subLabel.text = nil
            return
        }
        self.subLabel.text = subLabel
    }
    
    func configureSubLabel(label: String?) {
        guard let label = label else {
            self.subLabel.text = nil
            return
        }
        
        self.subLabel.text = label
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
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = .black
        
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        subLabel.textColor = UIColor("#AEAFB4")
        
        var labelsStackView = UIStackView()
        labelsStackView = UIStackView(arrangedSubviews: [nameLabel, subLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 2
        labelsStackView.alignment = .leading
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView = UIStackView(arrangedSubviews: [labelsStackView, imageView])
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
