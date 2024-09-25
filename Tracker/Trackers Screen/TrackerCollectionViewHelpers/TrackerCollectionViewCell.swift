//  Created by Artem Morozov on 31.07.2024.

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func cellButtonDidTapped(_ cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "trackerCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private lazy var colorView: UIView = UIView()
    private lazy var nameLabel: UILabel = UILabel()
    private lazy var emojiView: UIView = UIView()
    private lazy var emojiLabel: UILabel = UILabel()
    private lazy var pinSquare: UIImageView = UIImageView()
    
    private let plusButton: UIButton = UIButton()
    private var daysCountLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        
    }
    
    override func prepareForReuse() {
        colorView.backgroundColor = .clear
        nameLabel.text = ""
        emojiView.backgroundColor = .clear
        plusButton.setBackgroundImage(nil, for: .normal)
        daysCountLabel.text = nil
        pinSquare.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(name: String, emoji: String, color: UIColor, delegate: TrackerCollectionViewCellDelegate, trackerIsPin: Bool) {
        self.nameLabel.text = name
        self.emojiLabel.text = emoji
        self.colorView.backgroundColor = color
        self.emojiView.backgroundColor = .white.withAlphaComponent(0.3)
        self.plusButton.backgroundColor = color
        self.delegate = delegate
        self.pinSquare.image = trackerIsPin ? UIImage(named: "pinSquare") : nil
        
    }
    
    func trackerStateChange(days: Int, trackerCompletedToday: Bool, trackerType: TrackerType) {
        switch trackerType {
            
        case .habit:
            let daysString = String.localizedStringWithFormat(
                NSLocalizedString("numberOfDays", comment: "Number of days"),
                days
            )
            
            if trackerCompletedToday {
                daysCountLabel.text = daysString //formateDays(days)
                plusButton.setImage(UIImage(named: "Done"), for: .normal)
                plusButton.backgroundColor = plusButton.backgroundColor?.withAlphaComponent(0.3)
            } else {
                daysCountLabel.text = daysString //formateDays(days)
                plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                plusButton.backgroundColor = plusButton.backgroundColor?.withAlphaComponent(1)
            }
        case .notRegularEvent:
            if trackerCompletedToday || days > 0 {
                daysCountLabel.text = "Выполнено"
                plusButton.setImage(UIImage(named: "Done"), for: .normal)
                plusButton.backgroundColor = plusButton.backgroundColor?.withAlphaComponent(0.3)
            } else {
                daysCountLabel.text = "Не выполнено"
                plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                plusButton.backgroundColor = plusButton.backgroundColor?.withAlphaComponent(1)
            }
        }
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
        configurePinSquare()
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
        plusButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc func buttonTapped() {
        delegate?.cellButtonDidTapped(self)
    }
    
    func configureDaysCountLabel() {
        contentView.addSubview(daysCountLabel)
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        daysCountLabel.font = UIFont.systemFont(ofSize: 14)
        daysCountLabel.textColor = .black
        
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
        emojiLabel.font = .systemFont(ofSize: 12)
        
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
        nameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .left
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            nameLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiView.bottomAnchor)
        ])
    }
    
    func configurePinSquare() {
        pinSquare.contentMode = .center
        pinSquare.image = UIImage(named: "pinSquare")
        pinSquare.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.addSubview(pinSquare)
        
        NSLayoutConstraint.activate([
            pinSquare.heightAnchor.constraint(equalToConstant: 24),
            pinSquare.widthAnchor.constraint(equalToConstant: 24),
            pinSquare.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -4),
            pinSquare.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor)
        ])
    }
}
