//  Created by Artem Morozov on 13.08.2024.

import UIKit

final class CreatingNotRegularEventViewController: UIViewController {
    private lazy var nameTrackerTextField = PaddedTextField()
    private lazy var tableView = UITableView()
    private lazy var cancelButton = UIButton(type: .system)
    private lazy var createButton = UIButton(type: .system)
    
    private let delegate: CreateHabitDelegate?
    
    private var tableViewData: [CellData] = [CellData(title: "Категория")]
    
    private var createButtonIsEnabled: Bool {
        let nameTrackerTextFieldIsEmpty = nameTrackerTextField.text?.isEmpty ?? true
        return !nameTrackerTextFieldIsEmpty
    }
    
    init(delegate: CreateHabitDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCreateButtonState), name: UITextField.textDidChangeNotification, object: nameTrackerTextField)
    }
    
   


@objc private func updateCreateButtonState() {
   if createButtonIsEnabled {
       createButton.backgroundColor = .black
       createButton.isEnabled = true
   } else {
       createButton.backgroundColor = UIColor("#AEAFB4")
       createButton.isEnabled = false
   }
}
}

extension CreatingNotRegularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreatingHabitTableViewCell.reuseIdentifier, for: indexPath)
        
        guard let creatingHabitTableViewCell = cell as? CreatingHabitTableViewCell else {return UITableViewCell()}
        creatingHabitTableViewCell.configureCell(nameLabel: tableViewData[indexPath.row].title, subLabel: tableViewData[indexPath.row].subTitle)
        return creatingHabitTableViewCell
    }
}

extension CreatingNotRegularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            print("Тут будет открытие экрана создания категории")
        default:
            print("Неизвестная ячейка")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: Configure UI
private extension CreatingNotRegularEventViewController {
    func configureUI() {
        view.backgroundColor = .white
        self.title = "Новое нерегулярное событие"
        
        configureNameTrackerTextField()
        configureTableView()
        configureCancelButton()
    }
    
    func configureNameTrackerTextField() {
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.placeholder = "Введите название трекера"
        nameTrackerTextField.textColor = .black
        nameTrackerTextField.backgroundColor = UIColor("#E6E8EB", alpha: 0.3)
        nameTrackerTextField.textAlignment = .left
        nameTrackerTextField.layer.cornerRadius = 16
        nameTrackerTextField.clipsToBounds = true
        
        self.view.addSubview(nameTrackerTextField)
        
        NSLayoutConstraint.activate([
            nameTrackerTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75)
            
        ])
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CreatingHabitTableViewCell.self, forCellReuseIdentifier: CreatingHabitTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    func configureCancelButton() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(UIColor("#F56B6C"), for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor("#F56B6C").cgColor
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = UIColor("#AEAFB4")
        createButton.setTitleColor(.white, for: .normal)
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.clipsToBounds = true
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped() {
        self.dismiss(animated: true)
        delegate?.didCreateHabit(TrackerCategory(header: "Категория Q",
                                                 trackers: [Tracker(
                                                    id: UUID(),
                                                    name: nameTrackerTextField.text ?? "",
                                                    color: .gray,
                                                    emoji: "📯",
                                                    schedule: [])
                                                 ]
                                                ))
    }
}
