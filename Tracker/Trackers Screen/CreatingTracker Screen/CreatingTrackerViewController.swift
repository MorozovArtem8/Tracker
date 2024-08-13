//  Created by Artem Morozov on 07.08.2024.

import UIKit

enum TrackerType {
    case habit
    case notRegularEvent
}

final class CreatingTrackerViewController: UIViewController {
    private let addHabit: UIButton = UIButton()
    private let notRegularEvent: UIButton = UIButton()
    
    private weak var delegate: TrackerTypeSelectionDelegate?
    
    init(delegate: TrackerTypeSelectionDelegate) {
        self.delegate = delegate
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        addHabit.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addHabit.layer.cornerRadius = 16
        addHabit.clipsToBounds = true
        addHabit.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        
        notRegularEvent.translatesAutoresizingMaskIntoConstraints = false
        notRegularEvent.backgroundColor = UIColor("#1A1B22")
        notRegularEvent.setTitle("Нерегулярное cобытие", for: .normal)
        notRegularEvent.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        notRegularEvent.layer.cornerRadius = 16
        notRegularEvent.clipsToBounds = true
        notRegularEvent.addTarget(self, action: #selector(notRegularEventButtonTapped), for: .touchUpInside)
        
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
    
    @objc func habitButtonTapped() {
        delegate?.didSelectTrackerType(self, trackerType: .habit)
    }
    
    @objc func notRegularEventButtonTapped() {
        delegate?.didSelectTrackerType(self, trackerType: .notRegularEvent)
    }
}
