//  Created by Artem Morozov on 25.09.2024.

import UIKit

final class StatisticTableViewCell: UITableViewCell {
    static let reuseIdentifier = "StatisticTableViewCellReuseIdentifier"
    
    private lazy var customContentView = GradientBoarderView()
    private lazy var countLabel = UILabel()
    private lazy var textInfoLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(countLabel: String, textInfoLabel: String) {
        self.countLabel.text = countLabel
        self.textInfoLabel.text = textInfoLabel
    }
    
}

//MARK: Configure UI

private extension StatisticTableViewCell {
    func configureUI() {
        self.backgroundColor = .white
        configureCustomContentView()
        configureLabels()
    }
    
    func configureCustomContentView() {
        customContentView.clipsToBounds = true
        customContentView.layer.cornerRadius = 16
        customContentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(customContentView)
        
        NSLayoutConstraint.activate([
            customContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            customContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            customContentView.heightAnchor.constraint(equalToConstant: 90)
            
        ])
    }
    
    func configureLabels() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        textInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        textInfoLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        countLabel.textColor = .black
        textInfoLabel.textColor = .black
        
        customContentView.addSubview(countLabel)
        customContentView.addSubview(textInfoLabel)
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: customContentView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: customContentView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor, constant: -12),
            
            textInfoLabel.bottomAnchor.constraint(equalTo: customContentView.bottomAnchor, constant: -12),
            textInfoLabel.leadingAnchor.constraint(equalTo: customContentView.leadingAnchor, constant: 12),
            textInfoLabel.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor, constant: -12),
        ])
    }
}



