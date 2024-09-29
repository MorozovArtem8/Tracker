//  Created by Artem Morozov on 16.08.2024.

import UIKit

final class CreateTrackerCollectionViewEmojiCell: UICollectionViewCell {
    static let identifier: String = "createTrackerEmojiCell"
    
    private lazy var emojiLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    override func prepareForReuse() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(emoji: String) {
        self.emojiLabel.text = emoji
        
    }
    
    func selectCell(select: Bool) {
        self.backgroundColor = select ? UIColor("#E6E8EB") : .clear
    }
}

//MARK: Configure UI

private extension CreateTrackerCollectionViewEmojiCell {
    func configureUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        configureEmojiLabel()
    }
    
    func configureEmojiLabel() {
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
}
