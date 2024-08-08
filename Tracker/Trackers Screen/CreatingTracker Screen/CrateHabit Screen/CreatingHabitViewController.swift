//  Created by Artem Morozov on 08.08.2024.

import UIKit

final class CreatingHabitViewController: UIViewController {
    
    
    
    private lazy var nameTrackerTextField = PaddedTextField()
    private lazy var tableView = UITableView()
    
    let tableViewData = ["Категория", "Рассписание"]
    
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
        creatingHabitTableViewCell.configureCell(nameLabel: tableViewData[indexPath.row])
        return creatingHabitTableViewCell
    }
}

extension CreatingHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] 
        }
        
        if indexPath.row == tableViewData.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
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
}
