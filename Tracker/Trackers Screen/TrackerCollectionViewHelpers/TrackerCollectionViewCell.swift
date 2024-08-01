//  Created by Artem Morozov on 31.07.2024.

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "trackerCell"
    
    let colorView: UIView = UIView()
    let nameLabel: UILabel = UILabel()
    let emojiView: UIView = UIView()
    let emojiLabel: UILabel = UILabel()
    
    let plusButton: UIButton = UIButton()
    let daysCountLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        
    }
    
    override func prepareForReuse() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Configure UI
private extension TrackerCollectionViewCell {
    func configureUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        
        
        configureColorView()
        configurePlusButton()
        configureDaysCountLabel()
        configureEmojiView()
        configureNameLabel()
    }
    
    func configureColorView() {
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.backgroundColor = UIColor("7994F5")
        colorView.layer.masksToBounds = true
        colorView.layer.cornerRadius = 16
        colorView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] 
        
        let colorViewHeight = self.frame.height / 1.64
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: colorViewHeight)
        ])
    }
    
    func configurePlusButton() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.backgroundColor = UIColor("7994F5")
        plusButton.layer.masksToBounds = true
        plusButton.layer.cornerRadius = 17
        plusButton.tintColor = .white
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configureDaysCountLabel() {
        contentView.addSubview(daysCountLabel)
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        daysCountLabel.text = "1 день"
        daysCountLabel.font = UIFont.systemFont(ofSize: 14)
        daysCountLabel.textColor = .black
        daysCountLabel.textAlignment = .left
        
        NSLayoutConstraint.activate([
            daysCountLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.trailingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: -8)
        ])
    }
    
    func configureEmojiView() {
        colorView.addSubview(emojiView)
        emojiView.addSubview(emojiLabel)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.backgroundColor = .white.withAlphaComponent(0.3)
        emojiView.layer.masksToBounds = true
        emojiView.layer.cornerRadius = 12
        emojiView.alpha = 30
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.text = "❤️"
        emojiLabel.font = .systemFont(ofSize: 14)
        
        NSLayoutConstraint.activate([
            emojiView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor)
            
        ])
    }
    
    func configureNameLabel() {
        colorView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .left
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            nameLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiView.bottomAnchor)
        ])
    }
}
