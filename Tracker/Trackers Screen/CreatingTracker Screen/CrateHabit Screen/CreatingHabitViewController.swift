//  Created by Artem Morozov on 08.08.2024.

import UIKit

final class CreatingHabitViewController: UIViewController {
    
    private lazy var nameTrackerTextField = PaddedTextField()
    private lazy var tableView = UITableView()
    private lazy var cancelButton = UIButton(type: .system)
    private lazy var createButton = UIButton(type: .system)
    
    private let delegate: CreateHabitDelegate?
    
    private var tableViewData: [CellData] = [CellData(title: "Категория"), CellData(title: "Расписание")]
    
    private var selectedDays: [DaysWeek] = [] {
        didSet {
            print(selectedDays)
        }
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
    }
}

extension CreatingHabitViewController: UITableViewDataSource {
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

extension CreatingHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            print("Тут будет открытие экрана создания категории")
        case 1:
            let scheduleScreenViewController = ScheduleScreenViewController()
            scheduleScreenViewController.completionHandler = { [weak self] data in
                self?.selectedDays = data
                //TODO: сделать функцию для конвертации массива дней недели в строку для отображения subTitle
                self?.tableViewData[1].subTitle = "Вт, Cб"
                self?.tableView.reloadData()
            }
            
            let navigationController = UINavigationController(rootViewController: scheduleScreenViewController)
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            navigationController.navigationBar.titleTextAttributes = textAttributes
            present(navigationController, animated: true)
        default:
            print("Неизвестная ячейка")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        if indexPath.row == tableViewData.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: Configure UI
private extension CreatingHabitViewController {
    func configureUI() {
        view.backgroundColor = .white
        self.title = "Новая привычка"
        
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
        delegate?.didCreateHabit(TrackerCategory(header: "Категория",
                                                 trackers: [Tracker(
                                                    id: UUID(),
                                                    name: nameTrackerTextField.text ?? "",
                                                    color: .gray,
                                                    emoji: "📯",
                                                    schedule: self.selectedDays)
                                                 ]
                                                ))
    }
}
