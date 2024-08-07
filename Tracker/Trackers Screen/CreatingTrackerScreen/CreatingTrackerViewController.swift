//  Created by Artem Morozov on 07.08.2024.

import UIKit

final class CreatingTrackerViewController: UIViewController {
    private let addHabit: UIButton = UIButton()
    private let notRegularEvent: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

//MARK: Configure UI
private extension CreatingTrackerViewController {
    func configureUI() {
        view.backgroundColor = .white
        self.title = "Создание трекера"
        configureButtons()
    }
    
    func configureButtons(){
        addHabit.translatesAutoresizingMaskIntoConstraints = false
        addHabit.backgroundColor = UIColor("#1A1B22")
        addHabit.setTitle("Привычка", for: .normal)
        addHabit.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addHabit.layer.cornerRadius = 16
        addHabit.clipsToBounds = true
        
        notRegularEvent.translatesAutoresizingMaskIntoConstraints = false
        notRegularEvent.backgroundColor = UIColor("#1A1B22")
        notRegularEvent.setTitle("Нерегулярное cобытие", for: .normal)
        notRegularEvent.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        notRegularEvent.layer.cornerRadius = 16
        notRegularEvent.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [addHabit, notRegularEvent])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            addHabit.heightAnchor.constraint(equalToConstant: 60),
            notRegularEvent.heightAnchor.constraint(equalToConstant: 60),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    @objc func buttonTapped() {
       
    }
}
